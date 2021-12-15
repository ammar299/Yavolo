class Admin::OrdersController < Admin::BaseController

  before_action :set_order, only: :show

  def index
    @q = Order.ransack(params[:q])
    @orders = @q.result
    @orders = @orders.order(sub_total: :desc) if params.dig(:q, :s) == "price"
    @orders = @orders.page(params[:page]).per(params[:per_page].presence || 10)
  end

  def show
    @order_detail = @order.order_detail
    @order_line_items = @order.line_items
    @order_shipping_address = @order.shipping_address
    @order_billing_address = @order.billing_address
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
    order_ids = get_orders()
    # all_orders = []
    # order_ids.each do |order|
    #   order = Order.find(order)
    #   all_orders << order
    # end
    # if all_orders.count > 50
      ExportOrdersCsvWorker.perform_async(current_admin.id, current_admin.class.name, order_ids )
      redirect_to admin_orders_path, notice: 'Orders export started, You will receive a file when its completed.'
    # else
    #   exporter = Orders::Exporter.call({ owner: all_orders })
    #   if exporter.status
    #     respond_to do |format|
    #       format.csv { send_data exporter.csv_file, filename: "orders_#{Time.zone.now.to_i}.csv" }
    #     end
    #   else
    #     render json: { error: exporter.errors.first.to_s }
    #   end
    # end
  end

  def get_orders
    orders = []
    order_ids = params[:orders].split(",")
    order_ids.each do |order|
      orders << order.to_i
    end
    return orders
  end

  private

  def set_order
    @order = Order.find(params[:id])
  end
end
