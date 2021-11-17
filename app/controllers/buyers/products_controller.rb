class Buyers::ProductsController < ApplicationController

  layout 'buyers/buyer'

  def show
    if params[:preview_listing]
      @product = session[:preview_listing][:product]
    else
      @product = Product.find_by_handle(params[:id])
    end
  end
end
