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

end
