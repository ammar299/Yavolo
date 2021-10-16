class AddCategoryIdStringColumnToCategories < ActiveRecord::Migration[6.1]
  def change
    add_column :categories, :category_id_string, :string
    add_column :categories, :url, :string
  end
end
