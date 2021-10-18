class AddFilterCategoryIdsColumnToProducts < ActiveRecord::Migration[6.1]
  def change
    add_column :products, :filter_in_category_ids, :text, default: ""
  end
end
