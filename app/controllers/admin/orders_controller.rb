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
        render pdf: "Order_#{@order.id}",
               template: 'admin/orders/download_order.pdf.erb',
               layout: false,
               disposition: 'attachment'
      }
    end
  end

  private

  def set_order
    @order = Order.find(params[:id])
  end
end
