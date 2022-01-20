class Admin::OrdersController < Admin::BaseController

  include RefundingMethods

  before_action :current_order, only: :show

  def index
    @q = if params[:q].present? && params[:q].key?('search_product_a_to_z')
           Order.paid_orders_listing.ransack({ search_product_a_to_z: params[:q][:search_product_a_to_z] })
         elsif params[:q].present? && params[:q].key?('search_product_z_to_a')
           Order.paid_orders_listing.ransack({ search_product_z_to_a: params[:q][:search_product_z_to_a] })
         else
           Order.paid_orders_listing.ransack(params[:q])
         end
    @orders = @q.result(distinct: true)
    @orders = Order.paid_orders_listing if !params[:q].present? && !params[:filter_type].present? && !params[:csfname].present?
    @orders = @orders.order(sub_total: :desc) if params.dig(:q, :s) == "price"
    @orders = @orders.joins(:line_items).joins('inner join yavolo_bundle_products on line_items.product_id = yavolo_bundle_products.product_id') if params.dig(:q, :s) == 'yavolo'
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
    redirect_to admin_orders_path, flash: { notice: 'Orders export started, You will receive a file when its completed.' }
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
