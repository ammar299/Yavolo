require "paypal-checkout-sdk"
include PayPalCheckoutSdk::Payments
include PaypalPayoutsSdk::Payouts

module Paypal
  class PaypalOrderPaymentRefund < ApplicationService
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
        next if refund_detail[1]["amount_refund"].blank?
        line_item = ::LineItem.find_by(id: refund_detail[1]["line_item_id"]) rescue nil
        # we will do paypal reversal payout and refunding here.
        # @paypal_response = cancel_payout_item(line_item.transfer_id, debug)
        # @paypal_response = refund_capture(capture_id, refund_price, debug)
      end
    end

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
    def refund_capture (capture_id, refund_price, debug = false)
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

    # Cancels an UNCLAIMED payout item
    # An item can be cancelled only when the item status is UNCLAIMED and the batch status is SUCCESS
    # Upon cancelling the item status becomes RETURNED and the funds returned back to the sender
    def cancel_payout_item(item_id, debug = false)
      request = PayoutsGetRequest.new(item_id)
      begin
        response = @client.execute(request)
        puts "Status Code:  #{response.status_code}"
        puts "Status: #{response.result.status}"
        puts "Payout Item Id: #{response.result.payout_item_id}"
        puts "Payout Item Status: #{response.result.transaction_status}"
        puts "Links: "
        for link in response.result.links
          # this could also be called as link.rel or link.href but as method is a reserved keyword for ruby avoid calling link.method
          puts "\t#{link["rel"]}: #{link["href"]}\tCall Type: #{link["method"]}"
        end
        puts PayPalClient::openstruct_to_hash(response.result).to_json
        return response
      rescue PayPalHttp::HttpError => ioe
        # Exception occured while processing the payouts.
        puts " Status Code: #{ioe.status_code}"
        puts " Debug Id: #{ioe.result.debug_id}"
        puts " Response: #{ioe.result}"
      end
    end
  end
end
