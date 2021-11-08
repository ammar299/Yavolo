module Buyers::CartHelper

  def product_cart_images(product)
    product.pictures.first.name.url rescue 'profile.jpg' 
  end

end
