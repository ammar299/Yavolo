class Sellers::OrdersController < Sellers::BaseController

  before_action :validate_seller_dashboard!

  include ParseSortParam
  include RefundingMethods
  before_action :current_order, only: :show

  def index
    parse_sort_param_to_array
    @listing_by_order_status_with_count = Order.paid_orders_listing.seller_orders(current_seller).count
    @q = Order.paid_orders_listing.ransack(params[:q])
    @seller_orders = @q.result(distinct: true).seller_orders(current_seller)
    @seller_orders = @seller_orders.order(created_at: :desc) if params.dig(:q, :s).blank?
    @seller_orders = @seller_orders.page(params[:page]).per(params[:per_page].presence || 10)
  end

  def show
    super
    @order_line_items = @order.line_items.user_own_order_line_items(current_seller)
    respond_to do |format|
      format.html
      format.pdf {
        render pdf: "Order_#{@order.order_number}",
               template: 'sellers/orders/download_order.pdf.erb',
               layout: false,
               disposition: 'attachment'
      }
    end
  end

end
