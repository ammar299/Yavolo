class AddIndexToFilterInCategories < ActiveRecord::Migration[6.1]
  def change
    add_index :filter_in_categories, :filter_group_id
  end
end
