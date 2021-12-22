class Sellers::OrdersController < Sellers::BaseController

  before_action :set_order, only: :show
  include ParseSortParam

  def index
    parse_sort_param_to_array
    @listing_by_order_status_with_count = Order.paid_orders_listing.seller_orders(current_seller).count
    @q = Order.paid_orders_listing.ransack(params[:q])
    @seller_orders = @q.result(distinct: true).seller_orders(current_seller)
    @seller_orders = @seller_orders.order(created_at: :desc) if params.dig(:q, :s).blank?
    @seller_orders = @seller_orders.page(params[:page]).per(params[:per_page].presence || 10)
  end

  def show
    @order_detail = @order.order_detail
    @order_line_items = @order.line_items
    @order_shipping_address = @order.shipping_address
    @order_billing_address = @order.billing_address
  end

  private

  def set_order
    @order = Order.find(params[:id])
  end

end
