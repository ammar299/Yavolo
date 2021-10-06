class Admin::ProductsController < Admin::BaseController
  def index
    @products = Product.order(:title).page(params[:page]).per(params[:per_page].presence || 15)
  end
end
