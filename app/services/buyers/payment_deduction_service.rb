module Buyers

  class PaymentDeductionService < ApplicationService
    attr_reader :buyer, :value_after_paypal
    def initialize(buyer:, value_after_paypal:)
      @buyer = buyer
      @valueAfterPaypal = value_after_paypal
    end

    def call(*args)
      # create_referal
    end

    def create_referal
      @valueAfterPaypal = @valueAfterPaypal.to_f * 1
      @yavoloCommission = 50.00
      @finalAmountToSeller = @valueAfterPaypal - ((@yavoloCommission / 100) * @valueAfterPaypal)
      @access_token = self.class.get_token
      uri = URI.parse("https://api-m.sandbox.paypal.com/v1/payments/payouts")
      request = Net::HTTP::Post.new(uri)
      request.content_type = "application/json"
      request["Authorization"] = "Bearer #{@access_token}"
      request.body = JSON.dump({
        sender_batch_header: {
          recipient_type: 'EMAIL',
          sender_batch_id: 'Yov',
          email_subject: 'You have a payout!',
          email_message: 'You have received a payout! Thanks for using Yavolo service!'
        },
        items: [{
              note: 'Your Payout!',
              amount: {
                  currency: 'USD',
                  value: "#{@finalAmountToSeller}"
              },
              receiver: 'naseer.ahmad@phaedrasolutions.com',
              sender_item_id: 'Test_txn_1'
          }]
      })
      req_options = {
        use_ssl: uri.scheme == "https",
      }
      response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
        http.request(request)
      end
      response_body = JSON.parse(response.body)
    end

    def self.get_token
      uri = URI.parse("https://api-m.sandbox.paypal.com/v1/oauth2/token")
      request = Net::HTTP::Post.new(uri)
      request.basic_auth("#{ENV['PAYPAL_CLIENT_ID']}", "#{ENV['PAYPAL_CLIENT_SECRET']}")
      request["Accept"] = "application/json"
      request["Accept-Language"] = "en_US"
      request.set_form_data(
        "grant_type" => "client_credentials",
      )
      req_options = {
        use_ssl: uri.scheme == "https",
      }
      response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
        http.request(request)
      end
      response_body = JSON.parse(response.body)
      @access_token = response_body["access_token"]
      app_id = response_body["app_id"]
      token_type = response_body["token_type"]
      return @access_token
    end
end

end
