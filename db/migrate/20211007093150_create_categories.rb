class CreateCategories < ActiveRecord::Migration[6.1]
  def change
    create_table :categories do |t|
      t.string :category_name
      t.boolean :baby_category , default: false
      t.string :category_description
      t.string :bundle_label

      t.timestamps
    end
  end
end
