class Sellers::PaypalIntegrationsController < Sellers::BaseController
  # after_action :update_action_url, :only => [:check_onboarding_status]
  # before_action :authenticate_seller!, except: %i[check_onboarding_status_webhook]
  skip_before_action :authenticate_seller!, :only => :check_onboarding_status_webhook

  # require 'net/http'
  # require 'uri'
  # require 'json'
  # require 'openssl'

  def index
    @seller = current_seller
    @action_url = @seller&.paypal_detail&.seller_action_url
    @action_url = Sellers::PaypalIntegrationService.call({seller: current_seller}) if !@action_url.present?
  end

  def check_onboarding_status
    current_seller.paypal_detail.update(integration_status: true,seller_merchant_id_in_paypal: params[:merchantIdInPayPal])
    return render :json => {:status => true}, :status => :ok
  end

  def check_onboarding_status_webhook
    
  end

  # def update_onboarding_client_id
  #   @access_token = Sellers::PaypalIntegrationService.get_token
  #   merchant_id_in_paypal = current_seller.paypal_detail&.seller_merchant_id_in_paypal
  #   if merchant_id_in_paypal.present?
  #     uri = URI.parse("https://api-m.sandbox.paypal.com/v1/customer/partners/#{ENV['MERCHANT_ID']}/merchant-integrations/#{merchant_id_in_paypal}")
  #     request = Net::HTTP::Get.new(uri)
  #     request.content_type = "application/json"
  #     request["Authorization"] = "Bearer #{@access_token}"

  #     req_options = {
  #       use_ssl: uri.scheme == "https",
  #     }

  #     response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
  #       http.request(request)
  #     end
  #     response_body = JSON.parse(response.body)
  #     @seller_client_id = response_body["oauth_integrations"][0]["oauth_third_party"][0]["merchant_client_id"]
  #     @seller = current_seller
  #     if response.code == "200"
  #       update_paypal_details = @seller.paypal_detail.update(integration_status: true,seller_merchant_id_in_paypal: response_body["merchant_id"],seller_client_id: @seller_client_id)
  #       # return render :json => {:status => true}, :status => :ok
  #     else
  #       update_paypal_details = @seller.paypal_detail.update(integration_status: false)
  #       return render :json => {:status => false}, :status => :ok
  #     end 
  #   end
  # end

  private

  def update_action_url
    @action_url = Sellers::PaypalIntegrationService.call({seller: current_seller})
  end

end