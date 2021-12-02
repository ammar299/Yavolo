class Buyers::OrderStepsController < ApplicationController
  include Wicked::Wizard
  steps :view_cart, :checkout_details, :payment_method, :review_order, :submit_order

  def show
    if current_step?(:view_cart)
      view_cart_variables
    elsif current_step?(:checkout_details)
      initial_checkout_details_form
    end
    render_wizard
  end

  def update
    if current_step?(:checkout_details)
      create_checkout
    end
  end

  def view_cart_variables
    @cart = session[:_current_user_cart] ||= []
    product_ids = @cart.map{ |item| item[:product_id] }
    @products = Product.find(product_ids) rescue []
    @sub_total = sub_total
    @total = total
  end

  def initial_checkout_details_form
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

  def update_product_quantity_by_number
    update_product_quantity_by_number = update_product_quantity_by_number_params
    # todo only update if the product status is active
    # add status: :active in find_by
    @product = Product.find_by(id: update_product_quantity_by_number[:product_id]) rescue nil
    @cart = ''
    @cart_item = ''
    if @product.present?
      @cart = get_cart
      if update_product_quantity_by_number[:quantity].to_i < 1
        @cart.delete_if { |h| h[:product_id].to_i == @product.id }
        @sub_total = sub_total
        @total = total
        render :remove_product_form_cart
      else
        @cart.map { |h| 
          if h[:product_id].to_i == @product.id
            @cart_item = h
            h[:quantity] = update_product_quantity_by_number[:quantity].to_i
          end
        }
        # session[:_current_user_cart] = @cart
        @sub_total = sub_total
        @total = total
      end
    end
  end

  def remove_product_form_cart
    remove_product_params = remove_product_from_cart_params
    # todo only update if the product status is active
    # add status: :active in find_by
    @product = Product.find_by(id: remove_product_params[:product_id]) rescue nil
    if @product.present?
      @cart = get_cart
      @cart.delete_if { |h| h[:product_id].to_i == @product.id }
      @sub_total = sub_total
      @total = total
    end
  end

  private

  def sub_total
    cart = get_cart
    @sub_total = 0;
    cart.each do |item|
      product = Product.find(item[:product_id].to_i) rescue nil
        if product.present?
          @sub_total = @sub_total + (item[:quantity].to_i * product.price ? product.price.to_f : 0)
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
          @total = @total + item[:quantity].to_i * product.price ? product.price.to_f : 0
        end
    end
    return @total
  end

  def get_cart
    @cart = session[:_current_user_cart] ||= []
  end

  def session_order_id
    session[:_current_user_order_id] ||= nil
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

  def line_items_params
    line_items = session[:_current_user_cart]
    params[:order].merge!({line_items_attributes: line_items})
  end

  def remove_product_from_cart_params
    params.require(:remove_product).permit(:product_id)
  end

  def update_product_quantity_by_number_params
    params.require(:product_quantity).permit(:product_id, :quantity)
  end
end
