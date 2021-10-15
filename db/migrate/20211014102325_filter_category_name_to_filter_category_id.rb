class FilterCategoryNameToFilterCategoryId < ActiveRecord::Migration[6.1]
  def up
    remove_column :filter_categories, :category_name, :string
    add_column :filter_categories, :category_id, :integer
  end

  def down
    add_column :filter_categories, :category_name, :string
    remove_column :filter_categories, :category_id, :integer
  end
end
