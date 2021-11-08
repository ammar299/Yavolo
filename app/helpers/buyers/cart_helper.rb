module Buyers::CartHelper

  def product_cart_images(product)
    product.pictures.first.name.url rescue 'profile.jpg' 
  end

  def total_price(product, quantity)
    product[:price].to_f * quantity.to_i
  end

end
