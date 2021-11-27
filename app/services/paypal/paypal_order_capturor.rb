require 'paypal-checkout-sdk'
include PayPalCheckoutSdk::Orders
module Paypal
  class PaypalOrderCapturor < ApplicationService
    attr_reader :status, :errors, :params, :client, :paypal_response

    def initialize(params)
      super()
      @params = params
      @status = true
      @errors = []
      @paypal_response = nil
      @payment_capture_id = nil
    end

    def call
      begin
        paypal_client_creator = Paypal::PaypalClientCreator.call({})
        if paypal_client_creator.status
          @client = paypal_client_creator.client
        end
        @paypal_response = capture_order(order_id, debug)
      rescue StandardError => e
        @status = false
        @errors << e.message
      end
      self
    end


    private

    def debug
      @debug = params[:debug] ? true : false
    end

    def order_id
      @order_id ||= params[:order_id]
    end

    # This is the sample function performing payment capture on the order.
    # Approved Order id should be passed as an argument to this function
    def capture_order (order_id, debug=false)
      request = OrdersCaptureRequest::new(order_id)
      request.prefer("return=representation")

      response = @client.execute(request)
      if debug
        puts "Status Code: #{response.status_code}"
        puts "Status: #{response.result.status}"
        puts "Order ID: #{response.result.id}"
        puts "Intent: #{response.result.intent}"
        puts "Links:"
        for link in response.result.links
        # this could also be called as link.rel or link.href but as method is a reserved keyword for ruby avoid calling link.method
        puts "\t#{link["rel"]}: #{link["href"]}\tCall Type: #{link["method"]}"
        end
        puts "Capture Ids: "
        for purchase_unit in response.result.purchase_units
            for capture in purchase_unit.payments.captures
                puts "\t #{capture.id}"
                payment_capture_id = capture.id
            end
        end
        puts "Buyer:"
        buyer = response.result.payer
        # puts "\tEmail Address: #{buyer.email_address}\n\tName: #{buyer.name.full_name}\n\tPhone Number: #{buyer.phone.phone_number.national_number}"
        # puts PaypalClient::openstruct_to_hash(response.result).to_json
      end
      puts response
      return response, payment_capture_id
    end
  end
end
