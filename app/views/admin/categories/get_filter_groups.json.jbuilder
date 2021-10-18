json.data do
  json.filter_groups @category.filter_groups do |fg|
    json.id fg.id
    json.filter_name fg.name
    json.filter_in_categories fg.filter_in_categories do |fic|
      json.id fic.id
      json.name fic.filter_name
    end
  end
  if @product.present?
    json.filter_in_category_ids @product.filter_in_category_ids.map(&:to_i)
  else
    json.filter_in_category_ids []
  end
end
