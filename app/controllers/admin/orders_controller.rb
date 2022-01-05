class Admin::OrdersController < Admin::BaseController

  include RefundingMethods

  before_action :current_order, only: :show

  def index
    if params.dig(:q, :search_product_a_to_z).present?
      @q = Order.paid_orders_listing.ransack({ search_product_a_to_z: params[:q][:search_product_a_to_z] })
      @orders = @q.result
    elsif params.dig(:q, :search_product_z_to_a).present?
      @q = Order.paid_orders_listing.ransack({ search_product_z_to_a: params[:q][:search_product_z_to_a] })
      @orders = @q.result
    else
      @q = Order.paid_orders_listing.ransack(params[:q])
      @orders = @q.result(distinct: true)
    end
    @orders = @orders.order(sub_total: :desc) if params.dig(:q, :s) == "price"
    @total_count = @orders.size
    @orders = @orders.page(params[:page]).per(params[:per_page].presence || 15)
  end

  def show
    super
    @order_line_items = @order.line_items
    respond_to do |format|
      format.html
      format.pdf {
        render pdf: "Order_#{@order.order_number}",
               template: 'admin/orders/download_order.pdf.erb',
               layout: false,
               disposition: 'attachment'
      }
    end
  end

  def export_orders
    order_ids = get_orders
    ExportOrdersCsvWorker.perform_async(current_admin.id, current_admin.class.name, order_ids)
    redirect_to admin_orders_path, notice: 'Orders export started, You will receive a file when its completed.'
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
