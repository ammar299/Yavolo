class Admin::OrdersController < Admin::BaseController
  def index
    @q = Order.ransack(params[:q])
    @orders = @q.result
    @orders = @orders.page(params[:page]).per(params[:per_page].presence || 15)
  end
end
