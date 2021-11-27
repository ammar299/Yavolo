include PayPalCheckoutSdk
require 'paypal-checkout-sdk'

module Paypal
    class PaypalClientCreator < ApplicationService
    attr_reader :status, :errors, :params, :client

        def initialize(params)
            @params = params
            @status = true
            @errors = []
            @client = nil
        end

        def call
            begin
                set_client
            rescue StandardError => e
              @status = false
              @errors << e.message
            end
            self
        end

        private
        # Setting up and Returns PayPal SDK environment with PayPal Access credentials.
        # For demo purpose, we are using SandboxEnvironment. In production this will be
        # LiveEnvironment.
        def environment
            client_id = ENV['PAYPAL_CLIENT_ID']
            client_secret = ENV['PAYPAL_CLIENT_SECRET']
            
            PayPal::SandboxEnvironment.new(client_id, client_secret)
        end

        # Returns PayPal HTTP client instance with environment which has access
        # credentials context. This can be used invoke PayPal API's provided the
        # credentials have the access to do so.
        def set_client
            @client = PayPal::PayPalHttpClient.new(environment)
        end
    end
end