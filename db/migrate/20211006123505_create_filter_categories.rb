class CreateFilterCategories < ActiveRecord::Migration[6.1]
  def change
    create_table :filter_categories do |t|
      t.string :category_name
      t.integer :filter_group_id

      t.timestamps
    end
  end
end
