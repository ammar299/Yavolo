class CreateProductAssignmentSettings < ActiveRecord::Migration[6.1]
  def change
    create_table :product_assignment_settings do |t|
      t.decimal :price, precision: 8, scale: 2
      t.integer :items
      t.integer :duration

      t.timestamps
    end
  end
end
