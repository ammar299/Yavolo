require 'paypal-checkout-sdk'
include PayPalCheckoutSdk::Orders
module Paypal
  class PaypalOrderCreator < ApplicationService
    attr_reader :status, :errors, :params, :client, :paypal_response

    def initialize(params)
      super()
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
        @paypal_response = create_order(debug)
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

    def amount
      @amount = params[:amount] || 0
    end

    def currency_code
      @currency_code = params[:currency_code]
    end

    def create_application_context
      return_url = ENV['PAYPAL_RETURN_URL'] || 'https://eeec-182-179-134-113.ngrok.io'
      cancel_url = ENV['PAYPAL_CANCEL_URL'] || 'https://eeec-182-179-134-113.ngrok.io'
      brand_name = 'PhaerdraSolutions'

      {
        return_url: return_url,
        cancel_url: cancel_url,
        brand_name: brand_name,
        landing_page: 'BILLING',
        shipping_preference: 'SET_PROVIDED_ADDRESS',
        user_action: 'CONTINUE'
      }
    end

    def create_body(currency_code = 'GBP', amount = 10)
      # To have a better understanding of the body look sample body payload.
      {
        intent: 'CAPTURE',
        purchase_units: [
          amount: {
            currency_code: currency_code || 'GBP',
            value: amount
          }
        ]
      }
    end

    def create_order(debug = false)
      puts 'Creating order from service paypal create order'
      # Get body
      body = create_body(currency_code, amount)
      # create request
      request = OrdersCreateRequest::new
      # set preferred headers
      request.headers['prefer'] = 'return=representation'
      # assign body to the request
      request.request_body(body)

      response = @client.execute(request)

      # Use debug true to get the values printed in console
      # Note: Caution: Don't print the info in console when live
      if debug
        puts "Status Code: #{response.status_code}"
        puts "Status: #{response.result.status}"
        puts "Order ID: #{response.result.id}"
        puts "Intent: #{response.result.intent}"
        puts 'Links:'
        for link in response.result.links
          # this could also be called as link.rel or link.href but as method is a reserved keyword for ruby avoid calling link.method
          puts "\t#{link["rel"]}: #{link["href"]}\tCall Type: #{link["method"]}"
        end
        puts "Gross Amount: #{response.result.purchase_units[0].amount.currency_code} #{response.result.purchase_units[0].amount.value}"
      end
      response
    end
  end
end
