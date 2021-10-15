class CategoryExcludedFilterGroups < ActiveRecord::Migration[6.1]
  def change
    create_table :category_excluded_filter_groups do |t|
      t.integer :filter_group_id
      t.integer :category_id

      t.timestamps
    end
  end
end
