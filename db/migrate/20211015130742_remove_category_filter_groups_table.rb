class RemoveCategoryFilterGroupsTable < ActiveRecord::Migration[6.1]
  def change
    drop_table :category_filter_groups
  end
end
