class Buyers::OrdersController < Buyers::BaseController
  include Buyers::OrderStepsHelper

  def index
    @orders = current_buyer.orders
    @q = @orders.ransack(params[:q])
    @orders = @q.result(distinct: true)
    @orders = @orders.order(created_at: :desc) if params.dig(:q, :s).blank?
    @orders = @orders.page(params[:page]).per(params[:per_page].presence || 15)
  end

end