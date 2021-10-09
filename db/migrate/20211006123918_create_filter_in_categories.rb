class CreateFilterInCategories < ActiveRecord::Migration[6.1]
  def change
    create_table :filter_in_categories do |t|
      t.string :filter_name
      t.integer :sort_order
      t.integer :filter_group_id

      t.timestamps
    end
  end
end
