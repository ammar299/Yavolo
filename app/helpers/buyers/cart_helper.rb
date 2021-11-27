module Buyers::CartHelper

  def product_cart_images(product)
    product.pictures.first.name.url rescue 'profile.jpg' 
  end

  def total_price(product, quantity)
    product[:price].to_f * quantity.to_i
  end

  def default_payment_method
    'visa-card'
  end

  def payment_method(selected_payment_method = nil, payment_type)
    if selected_payment_method.present?
      payment_type == selected_payment_method ? true : false
    else
      payment_type == default_payment_method ? true : false
    end
  end

  def find_cart_product(product_id)
    Product.find(product_id)
  end

  def cart_sub_total
    cart = session[:_current_user_cart]
    sub_total = 0
    cart.each do |item|
      product = Product.find(item[:product_id].to_i)
      sub_total += (item[:quantity].to_i * product.price.to_f) if product.price.present?
    end
    sub_total.to_f
  end

end
