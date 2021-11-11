class Buyers::ProductsController < ApplicationController

  layout 'buyers/buyer'

  def show
    @product = Product.find_by_handle(params[:id])
  end
end
