class Buyers::ProductsController < ApplicationController

  layout 'buyers/buyer'

  def show
    # Yavolo bundles handle will start with text yavolobundle followed by 4 digits, then underscore, then bundle title
    if params[:id].match(Regexp.new(YavoloBundle::SLUG_REGEX_PATTERN))
      @yavolo_bundle = YavoloBundle.friendly.find(params[:id]) rescue nil
      render 'buyers/products/yavolo_bundle/show'
    else
      @product = Product.find_by_handle(params[:id])
      @product_status = @product.status
      if params[:preview_listing]
        terms_and_returns = @product.owner_type == "Seller" ? @product.owner&.return_and_term&.instructions : ""
        @product = session[:preview_listing][:product].merge("terms_and_returns" => terms_and_returns, stock: @product.stock)
      end
      if @product_status != 'active' && !params[:preview_listing]
        flash.now[:notice] = I18n.t('flash_messages.product_status_disable')
      end
    end

  end
end
