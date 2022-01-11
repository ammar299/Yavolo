require 'stripe'
module Stripe
  # This service is to create a stripe customer refund
  class RefundCreator < ApplicationService
    include RefundingValidationMethods

    attr_reader :status, :errors, :params, :response, :reversal_hash, :refund_hash

    def initialize(params)
      super()
      @params = params
      @status = true
      @errors = []
      @response = nil
      @reversal_hash = []
      @refund_hash = []
    end

    def call
      begin
        @response = refund_customer_charge_on_stripe
      rescue StandardError => e
        @status = false
        @errors << e.message
      end
      self
    end

    private

    def refund_customer_charge_on_stripe
      retrieve_line_items(params[:refund][:refund_details_attributes])
    end

    def retrieve_line_items(refund_details)
      refund_details.each do |refund_detail|
        parsed_params = parsing_line_item_param(refund_detail)
        next if parsed_params[:amount_refund].blank?
        api_processing_and_validations(parsed_params)
      end
    end

    def get_line_item(line_item_id)
      line_item_obj = ::LineItem.find_by(id: line_item_id) rescue nil
      {
        line_item_id: line_item_obj.id,
        order_id: line_item_obj.order_id,
        price: line_item_obj.price,
        quantity: line_item_obj.quantity,
        product_name: line_item_obj.product&.title,
        transfer_id: line_item_obj.transfer_id,
        total_paid: (line_item_obj.price * line_item_obj.quantity).to_f,
        seller_id: line_item_obj.product&.owner_id,
        buyer_id: line_item_obj.order&.buyer_id
      }
    end

    def api_processing_and_validations(parsed_params)
      line_item = get_line_item(parsed_params[:line_item_id])
      if refund_greater_than_paid?(parsed_params[:amount_refund], line_item[:total_paid])
        @errors << "Item: #{line_item[:product_name]}: £#{parsed_params[:amount_refund].to_f} should be less than actual total paid amount"
      elsif net_refund_greater_than_paid?(parsed_params[:amount_refund], line_item[:line_item_id])
        @errors << "Item: #{line_item[:product_name]}: £#{parsed_params[:amount_refund].to_f} should be less than so far generated refund against paid amount"
      else
        transfer_object = retrieve_a_transfer(line_item[:transfer_id])
        create_new_reversal(transfer_object, parsed_params)
      end
    end

    def parsing_line_item_param(line_item_param)
      {
        amount_refund: line_item_param[1]["amount_refund"],
        line_item_id: line_item_param[0],
      }
    end

    def retrieve_a_transfer(transfer_id)
      begin
        Stripe::Transfer.retrieve(transfer_id)
      rescue Stripe::StripeError => e
        @errors << "#{e.message}"
      end
    end

    def create_new_reversal(transfer_object, refund_param)
      line_item = get_line_item(refund_param[:line_item_id])
      begin
        create_reversal_request = Stripe::Transfer.create_reversal(
          transfer_object.id,
          {
            amount: get_amount_in_cents(refund_param[:amount_refund].to_i),
            description: "Transfer reversed for amount: £#{refund_param[:amount_refund]}"
          }
        )
        create_reversal_hash(create_reversal_request, refund_param)
        create_new_refund(transfer_object.source_transaction, refund_param)
      rescue Stripe::StripeError => e
        @errors << "Item: #{line_item[:product_name]}:" "#{e.message}"
      end
    end

    def create_reversal_hash(reversal_object, refund_param)
      line_item = get_line_item(refund_param[:line_item_id])
      @reversal_hash << {
        order_id: line_item[:order_id],
        seller_id: line_item[:seller_id],
        line_item_id: line_item[:line_item_id],
        transfer_id: reversal_object["transfer"],
        transfer_reversal_id: reversal_object["id"],
        reversal_through: :stripe,
        amount_reversed: refund_param[:amount_refund],
      }
    end

    def create_new_refund(charge_id, refund_param)
      line_item = get_line_item(refund_param[:line_item_id])
      begin
        create_refund = Stripe::Refund.create({
                                                charge: charge_id,
                                                metadata: { description: "£#{refund_param[:amount_refund]} refunded for order" },
                                                amount: get_amount_in_cents(refund_param[:amount_refund].to_i)
                                              })
        create_refund_hash(create_refund, refund_param)
      rescue Stripe::StripeError => e
        error_messages = change_error_messages_verbiage(e.message)
        @errors << "Item: #{line_item[:product_name]}:" "#{error_messages}"
      end
    end

    def create_refund_hash(refund_object, refund_param)
      line_item = get_line_item(refund_param[:line_item_id])
      @refund_hash << {
        order_id: line_item[:order_id],
        buyer_id: line_item[:buyer_id],
        line_item_id: line_item[:line_item_id],
        response_refund_id: refund_object["id"],
        charge_id: refund_object["charge"],
        amount_refund: refund_param[:amount_refund],
        refund_through: :stripe,
        status: refund_object["status"],
      }
    end

    # we can add more custom error messages here based on stripe response
    def change_error_messages_verbiage(message)
      if message.include?("has already been refunded")
        "Charge has already been refunded."
      else
        ""
      end
    end

    def get_amount_in_cents(amount)
      (amount * 100).to_i
    end
  end
end
