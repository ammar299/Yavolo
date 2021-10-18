class AddCategoryIdToFilterInCategories < ActiveRecord::Migration[6.1]
  def change
    add_column :filter_in_categories, :category_id, :integer
  end
end
