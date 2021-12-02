class Buyers::BaseController < ApplicationController
  before_action :authenticate_buyer!
  # layout 'buyers/buyer'
  layout 'buyers/checkout/buyer_checkout'
  before_action :updated_cart

  def updated_cart
    @cart = get_cart
    return if @cart.blank?

    @cart.each do |cart_item|
      product = Product.find_by(id: cart_item[:product_id])
      @cart.delete_if { |h| h[:product_id].to_i == cart_item[:product_id].to_i } if product.blank?
    end
    update_cart(@cart)
  end

  private
  def get_cart
    @cart = session[:_current_user_cart] ||= []
  end

  def update_cart(cart)
    session[:_current_user_cart] = cart
  end
end
