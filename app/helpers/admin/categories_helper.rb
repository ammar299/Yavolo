module Admin::CategoriesHelper
  def nested_categories(categories)
    categories.map do |category, sub_categories|
      content_tag(:ul, class: "#{category.root == category ? 'active':nil}") do
        content_tag(:li, ((render 'category', category: category) + nested_categories(sub_categories)).html_safe)
      end
    end.join.html_safe
  end

  def category_linking_filters(category_id)
    FilterInCategory.where(filter_group_id: FilterGroup.local_filter_groups.includes(:filter_categories).where(filter_categories: { category_id: category_id })).pluck(:filter_name, :id)
  end
end
