require "paypal-checkout-sdk"
include PayPalCheckoutSdk::Payments
module Paypal
    class PaypalOrderPaymentRefunder < ApplicationService
        attr_reader :status, :errors, :params, :client, :paypal_response

        def initialize(params)
            @params = params
            @status = true
            @errors = []
            @paypal_response = nil
        end

        def call
            begin
                paypal_client_creator = Paypal::PaypalClientCreator.call({})
                if paypal_client_creator.status
                    @client = paypal_client_creator.client
                end
                @paypal_response = refund_capture(capture_id, refund_price, debug)
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

        def capture_id
            @capture_id ||= params[:order_id]
        end

        def refund_price
            @refund_price = params[:refund_price]
        end

        #2. Set up your server to receive a call from the client
        # This sample function performs capturing a refund.
        # Pass a valid capture ID as an argument to this function.
        def refund_capture (capture_id, refund_price, debug=false)
            request = CapturesRefundRequest::new(capture_id)
            request.prefer("return=representation")
            # Populate the request body to do a partial refund.
            request.request_body({
            amount: {
                value: refund_price,
                currency_code: 'USD'
            }
            });
            #3. Call PayPal to refund an capture
            response = @client.execute(request)
            if debug
            puts "Status Code: " + response.status_code.to_s
            puts "Status: " + response.result.status
            puts "Order ID: " + response.result.id
            # puts "Intent: " + response.result.intent
            puts "Links:"
            for link in response.result.links
                # This could also be called as link.rel or link.href, but
                # as method is a reserved keyword for Ruby. Avoid calling link.method
                puts "\t#{link["rel"]}: #{link["href"]}\tCall Type: #{link["method"]}"
            end
            # puts PayPalClient::openstruct_to_hash(response.result).to_json
            end
            puts response
            return response
        end
    end
end