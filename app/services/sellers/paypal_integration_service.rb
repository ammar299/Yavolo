module Sellers

  class PaypalIntegrationService < ApplicationService
    attr_reader :seller
    def initialize(seller:)
      @seller = seller
    end

    def call(*args)
      create_referal
    end

    def create_referal
      @access_token = self.class.get_token
      create_seller_paypal_detail_entry
      uri = URI.parse("https://api-m.sandbox.paypal.com/v2/customer/partner-referrals")
      request = Net::HTTP::Post.new(uri)
      request.content_type = "application/json"
      request["Authorization"] = "Bearer #{@access_token}"
      request.body = JSON.dump({
        "tracking_id" => "#{@seller.paypal_detail.id}",
        "operations" => [
          {
            "operation" => "API_INTEGRATION",
            "api_integration_preference" => {
              "rest_api_integration" => {
                "integration_method" => "PAYPAL",
                "integration_type" => "THIRD_PARTY",
                "third_party_details" => {
                  "features" => [
                    "PAYMENT",
                    "REFUND"
                  ]
                }
              }
            }
          }
        ],
      "partner_config_override": {
        "partner_logo_url": "#{ENV['DEFAULT_HOST_URL']}/assets/Yavolo_Logo_WarmRed.png",
        "return_url": "https://#{ENV['DEFAULT_HOST_URL']}/sellers",
        "return_url_description": "the url to return the merchant after the paypal onboarding process.",
        "action_renewal_url": "https://testenterprises.com/renew-exprired-url",
        "show_add_credit_card": true
        },
        "products" => [
          "EXPRESS_CHECKOUT"
        ],
        "legal_consents" => [
          {
            "type" => "SHARE_DATA_CONSENT",
            "granted" => true
          }
        ]
      })
  
      req_options = {
        use_ssl: uri.scheme == "https",
      }
  
      response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
        http.request(request)
      end
      response_body = JSON.parse(response.body)
      @action_url = response_body["links"][1]["href"]
      # @self_url = response_body["links"][0]["href"]
      update_return_url
      return @action_url

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

    private

    def create_seller_paypal_detail_entry
      paypal_detail = @seller.create_paypal_detail(integration_status: false) if !@seller.paypal_detail.present?
    end

    def update_return_url
      paypal_detail = @seller.paypal_detail.update(seller_action_url: @action_url) if @seller.paypal_detail.present?
    end

  end

end