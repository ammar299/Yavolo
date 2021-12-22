class Buyers::ProductsController < ApplicationController

  layout 'buyers/buyer'

  def show
    @product = Product.find_by_handle(params[:id])
    unless @product.status == 'active'
      flash.now[:notice] = I18n.t('flash_messages.product_status_disable')
    end
    if params[:preview_listing]
      terms_and_returns = @product.owner_type == "Seller" ? @product.owner&.return_and_term&.instructions : ""
      @product = session[:preview_listing][:product].merge("terms_and_returns" => terms_and_returns)
    end
  end
end
