class AddIndexToFilterGroups < ActiveRecord::Migration[6.1]
  def change
    add_index :filter_groups, :name
  end
end
