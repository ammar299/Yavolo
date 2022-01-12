class Buyers::WishlistController < Buyers::BaseController
  include Buyers::ProfileHelper

  def index
    @fav_products = current_buyer.wishlist&.products
    @q = @fav_products.ransack(params[:q])
    @fav_products = @q.result(distinct: true)
    @fav_products = @fav_products.order(created_at: :desc) if params.dig(:q, :s).blank?
    @fav_products = @fav_products.page(params[:page]).per(params[:per_page].presence || 15)
  end

end