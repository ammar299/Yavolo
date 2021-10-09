class AddIndexToFilterCategories < ActiveRecord::Migration[6.1]
  def change
    add_index :filter_categories, :filter_group_id
  end
end
