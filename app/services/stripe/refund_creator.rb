require 'stripe'
module Stripe
  # This service is to create a stripe customer refund
  class RefundCreator < ApplicationService
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
        next if refund_detail[1]["amount_refund"].blank?
        line_item = ::LineItem.find_by(id: refund_detail[1]["line_item_id"]) rescue nil
        transfer_object = retrieve_a_transfer(line_item.transfer_id)
        create_new_reversal(transfer_object.id, refund_detail[1])
        create_new_refund(transfer_object.source_transaction, refund_detail[1])
      end
    end

    def create_new_reversal(transfer_id, refund_detail)
      product = get_product(refund_detail["product_id"])
      begin
        create_reversal_request = Stripe::Transfer.create_reversal(
          transfer_id,
          {
            amount: get_amount_in_cents(refund_detail["amount_refund"].to_i),
            description: "Transfer reversed for amount: £#{refund_detail["amount_refund"]}"
          }
        )
        create_reversal_hash(create_reversal_request, refund_detail)
      rescue Stripe::StripeError => e
        @errors << "Item: #{product.title}:" "#{e.message}"
      end
    end

    def create_reversal_hash(reversal_object, refund_detail)
      product_seller = get_product(refund_detail["product_id"])
      @reversal_hash << {
        order_id: refund_detail["order_id"],
        seller_id: product_seller.owner_id,
        line_item_id: refund_detail["line_item_id"],
        transfer_id: reversal_object["transfer"],
        transfer_reversal_id: reversal_object["id"],
        reversal_through: :stripe,
        amount_reversed: refund_detail["amount_refund"],
      }
    end

    def create_new_refund(charge_id, refund_detail)
      product = get_product(refund_detail["product_id"])
      begin
        create_refund = Stripe::Refund.create({
          charge: charge_id,
          metadata: { description: "£#{refund_detail["amount_refund"]} refunded for order" },
          amount: get_amount_in_cents(refund_detail["amount_refund"].to_i)
        })
        create_refund_hash(create_refund, refund_detail)
      rescue Stripe::StripeError => e
        error_messages = change_error_messages_verbiage(e.message)
        @errors << "Item: #{product.title}:" "#{error_messages}"
      end
    end

    def create_refund_hash(refund_object, refund_detail)
      get_order_buyer = get_order_buyer(refund_detail["order_id"])
      @refund_hash << {
        order_id: refund_detail["order_id"],
        buyer_id: get_order_buyer.buyer_id,
        line_item_id: refund_detail["line_item_id"],
        response_refund_id: refund_object["id"],
        charge_id: refund_object["charge"],
        amount_refund: refund_detail["amount_refund"],
        refund_through: :stripe,
        status: refund_object["status"],
      }
    end

    def retrieve_a_transfer(transfer_id)
      begin
        Stripe::Transfer.retrieve(transfer_id)
      rescue Stripe::StripeError => e
        @errors << "#{e.message}"
      end
    end

    # we can add more custom error messages here based on stripe response
    def change_error_messages_verbiage(message)
      if message.include?("has already been refunded")
        "Charge has already been refunded."
      else
        ""
      end
    end

    def get_product(product_id)
      ::Product.find_by(id: product_id) rescue nil
    end

    def get_order_buyer(order_id)
      ::Order.find_by(id: order_id) rescue nil
    end

    def get_amount_in_cents(amount)
      (amount * 100).to_i
    end
  end
end
