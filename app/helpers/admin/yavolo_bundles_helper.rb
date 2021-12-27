module Admin::YavoloBundlesHelper

  def get_featured_images_of_bundle_products(products)
    featured_images = []

    products.each do |product|
      featured_images << product.get_featured_image
    end
    featured_images.compact
  end

  def get_sellers_of_yavolo_bundle(bundle)
    bundle.products.includes(owner: :company_detail).map do |p|
      p.owner_type == 'Seller' ? p.owner&.company_detail&.name&.titleize : "Yavolo"
    end.compact.uniq.join(", ")
  end

  def get_specification_of_bundle_products(bundle)
    bundle.products.includes(category: [filter_groups: [:filter_in_categories]]).map do |p|
      specification = {
          title: p.title,
          filter_groups: []
      }
      specification[:filter_groups] = p.category.filter_groups.map do |fg|
        {
            name: fg.name,
            details: fg.filter_in_categories.pluck(:filter_name).join(", ")
        }
      end
      specification
    end
  end

  def get_return_and_terms_of_bundle_products(bundle)
    bundle.products.includes(owner: :return_and_term).map do |product|
      product.owner_type == "Seller" ?
          {title: product.title, instructions: product.owner&.return_and_term&.instructions} : nil
    end.compact
  end

end
