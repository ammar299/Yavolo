module Admin::CategoriesHelper
  def nested_categories(categories)
    content_tag(:ul) do
      categories.map do |category, sub_categories|
        content_tag(:li, ((render 'category', category: category) +  nested_categories(sub_categories)).html_safe)
      end.join.html_safe
    end
  end
end
