class CreateProductAssignments < ActiveRecord::Migration[6.1]
  def change
    create_table :product_assignments do |t|
      t.references :product, null: false, foreign_key: true
      t.integer :priority
      t.bigint :total_sales
      t.decimal :total_revenue, precision: 18, scale: 2

      t.timestamps
    end
  end
end
