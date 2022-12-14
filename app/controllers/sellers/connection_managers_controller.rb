class Sellers::ConnectionManagersController < Sellers::BaseController

  def new
    @seller_api = SellerApi.new
  end

  def create
     @seller_api = SellerApi.new(seller_api_params)
     @seller_api.seller_id = current_seller.id
     @seller_api.api_token = SecureRandom.hex(30)
     @seller_api.developer_id = SecureRandom.hex(7)
     @seller_api.expiry_date = Date.today + 6.month
     @seller_api.status = 'enable'
     @seller_api.save
     flash.now[:notice] = 'Seller API created successfully!'
  end

  def update
    if params[:field_to_update].present?
      @seller_api = SellerApi.find(params[:seller_api_id])
      if params[:field_to_update] == 'renew'
        @seller_api.api_token = SecureRandom.hex(30)
        @seller_api.developer_id = SecureRandom.hex(7)
        @seller_api.expiry_date = Date.today + 6.month
        @seller_api.save
        flash.now[:notice] = 'Seller API renewed successfully!'
      else
        @seller_api.update(status: params[:field_to_update])
        flash.now[:notice] = 'Seller API updated successfully!'
      end
    end
  end

  private
  def seller_api_params
    params.require(:seller_api).permit(:developer_name, :app_name)
  end
end
