module Buyers::ProfileHelper
  def product_thumbnail_image(product,version = :thumb)
    if product.pictures&.first&.name&.url&.present?
      product.pictures.first.name.url(version)
    else
      'default.jpg'
    end
  end
end
