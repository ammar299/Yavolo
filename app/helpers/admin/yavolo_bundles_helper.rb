module Admin::YavoloBundlesHelper

  def get_featured_images_of_bundle_products(products)
    featured_images = []

    products.each do |product|
      featured_images << product.get_featured_image
    end
    featured_images.compact
  end
end
