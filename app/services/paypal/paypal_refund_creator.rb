require "paypal-checkout-sdk"
include PayPalCheckoutSdk::Payments
include PayPalCheckoutSdk::Orders

module Paypal
  class PaypalRefundCreator < ApplicationService
    include RefundingValidationMethods

    attr_reader :status, :errors, :notices, :params, :client, :paypal_response

    def initialize(params)
      @params = params
      @status = true
      @errors = []
      @notices = []
      @paypal_response = nil
      @refund_hash = []
    end

    def call
      begin
        paypal_client_creator = Paypal::PaypalClientCreator.call({})
        if paypal_client_creator.status
          @client = paypal_client_creator.client
        end
        @paypal_response = refund_customer_charge_on_paypal
      rescue StandardError => e
        @status = false
        @errors << e.message
      end
      self
    end

    private

    def refund_customer_charge_on_paypal
      retrieve_line_items(params[:refund][:refund_details_attributes])
    end

    def retrieve_line_items(refund_details)
      refund_details.each do |refund_detail|
        parsed_params = parsing_line_item_param(refund_detail)
        next if parsed_params[:amount_refund].blank?
        line_item_ar_object = get_line_item(parsed_params[:line_item_id])
        actual_order_response = find_actual_order(line_item_ar_object[:order_id])
        paypal_order_response = find_paypal_order(actual_order_response&.payment_mode&.charge_id)
        parsed_order_response = parsing_order_response(paypal_order_response)
        api_processing_and_validations(parsed_params, parsed_order_response)
      end
    end

    def api_processing_and_validations(parsed_params, parsed_order)
      line_item = get_line_item(parsed_params[:line_item_id])
      if refund_greater_than_paid?(parsed_params[:amount_refund], line_item[:total_paid])
        @errors << "Item: #{line_item[:product_name]}: £#{parsed_params[:amount_refund].to_f} should be less than actual total paid amount.<br />"
      elsif net_refund_greater_than_paid?(parsed_params[:amount_refund], parsed_params[:line_item_id])
        @errors << "Item: #{line_item[:product_name]}: £#{parsed_params[:amount_refund].to_f} should be less than so far generated refund against paid amount.<br />"
      else
        refund_capture(parsed_params, parsed_order, line_item)
      end
    end

    def find_actual_order(order_id)
      ::Order.find_by(id: order_id) rescue nil
    end

    def find_paypal_order(order_id)
      request = OrdersGetRequest::new(order_id)
      begin
        response = @client.execute(request)
        Paypal::PaypalResponse.parsed_response(response.result)
      rescue PayPalHttp::HttpError => ioe
        @errors << "#{ioe.result.message}"
      end
    end

    def refund_capture(parsed_params, parsed_order, line_item)
      request = CapturesRefundRequest::new(parsed_order[:capture_id])
      request.prefer("return=representation")
      request.request_body({ amount: { value: parsed_params[:amount_refund].to_f, currency_code: 'GBP' } })
      begin
        response = @client.execute(request)
        parsed_response = Paypal::PaypalResponse.parsed_response(response.result)
        create_refund_hash(parsed_response, parsed_order, parsed_params)
      rescue PayPalHttp::HttpError => ioe
        @errors << "Item: #{line_item[:product_name]}: #{ioe.result.details[0]["description"]}.<br />"
      end
    end

    def create_refund_hash(refund_response, parsed_order, parsed_params)
      line_item = get_line_item(parsed_params[:line_item_id])
      @refund_hash << {
        "order_id" => line_item[:order_id],
        "buyer_id" => line_item[:buyer_id],
        "line_item_id" => line_item[:line_item_id],
        "response_refund_id" => refund_response["id"],
        "charge_id" => parsed_order[:capture_id],
        "amount_refund" => refund_response["amount"]["value"],
        "refund_through" => :paypal,
        "status" => refund_response["status"],
      }
      @notices << "Item: #{line_item[:product_name]}: Refund operation performed successfully.<br />"
    end

    def parsing_line_item_param(params)
      {
        amount_refund: params[1]["amount_refund"],
        line_item_id: params[0],
      }
    end

    def parsing_order_response(order_response)
      {
        capture_id: order_response["purchase_units"][0]["payments"]["captures"][0]["id"]
      }
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
  end
end
