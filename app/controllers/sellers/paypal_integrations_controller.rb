class Sellers::PaypalIntegrationsController < Sellers::BaseController

  def index
    @seller = current_seller
    @action_url = @seller&.paypal_detail&.seller_action_url
    @action_url = Sellers::PaypalIntegrationService.call({seller: current_seller}) if !@action_url.present?
  end

  def check_onboarding_status
    current_seller.paypal_detail.update(integration_status: true,seller_merchant_id_in_paypal: params[:merchantIdInPayPal])
    return render :json => {:status => true}, :status => :ok
  end

end