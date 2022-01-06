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
  def export_orders
    order_ids = get_orders
    ExportOrdersCsvWorker.perform_async(current_seller.id, current_seller.class.name, order_ids)
    redirect_to sellers_orders_path, notice: 'Orders export started, You will receive a file when its completed.'
  end

  def get_orders
    orders = []
    order_ids = params[:orders].split(",")
    order_ids.each do |order|
      orders << order.to_i
    end
    return orders
  end

end
