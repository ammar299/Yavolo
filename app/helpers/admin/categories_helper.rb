module Admin::CategoriesHelper
  def nested_categories(categories)
      categories.map do |category, sub_categories|
        content_tag(:ul, class: "#{category.root == category ? 'active':nil}") do
          content_tag(:li, ((render 'category', category: category) + nested_categories(sub_categories)).html_safe)
        end
      end.join.html_safe
  end
end
