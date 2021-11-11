class Buyers::CheckoutController < ApplicationController

  def index
  end

  def new
    @cart = get_cart
    @sub_total = sub_total
    @total = total
    @order_id = session_order_id
    if @order_id.present?
      @order = Order.find(@order_id) rescue nil
      session.delete(:_current_user_order_id) if !@order.present?
      @order = Order.new if !@order.present?
    else
      @order = Order.new
    end
  end

  def create_checkout
    order_line_item_params = order_params
    if params[:billing_address_is_shipping_address].present? && params[:billing_address_is_shipping_address] == "true"
      order_line_item_params[:shipping_address_attributes] = order_line_item_params[:billing_address_attributes]
    end
    @order_id = session_order_id
    if @order_id.present?
      @order = Order.find(@order_id).destroy
    end
    @order = Order.create(order_line_item_params)
    session[:_current_user_order_id] = @order.id
  end

  private
  def get_cart
    session[:_current_user_cart] ||= []
  end

  def sub_total
    cart = get_cart
    @sub_total = 0;
    cart.each do |item|
      product = Product.find(item[:product_id].to_i) rescue nil
        if product.present?
          @sub_total = @sub_total + (item[:quantity].to_i * product.price.to_f)
        end
    end
    return @sub_total
  end

  def total
    cart = get_cart
    @total = 0;
    cart.each do |item|
      product = Product.find(item[:product_id].to_i) rescue nil
        if product.present?
          @total = @total + item[:quantity].to_i * product.price.to_f
        end
    end
    return @total
  end

  def session_order_id
    session[:_current_user_order_id] ||= nil
  end

  def line_items_params
    line_items = session[:_current_user_cart]
    params[:order].merge!({line_items_attributes: line_items})
  end

  def order_params
    line_items_params
    params.require(:order).permit(
      order_detail_attributes: [:id, :name, :contact_number, :email, :_destroy],
      billing_address_attributes: [:id, :appartment, :address_line_1, :address_line_2, :city, :county, :country, :postal_code],
      shipping_address_attributes: [:id, :appartment, :address_line_1, :address_line_2, :city, :county, :country, :postal_code],
      line_items_attributes: [:id, :product_id, :quantity, :added_on]
    )
  end
end
