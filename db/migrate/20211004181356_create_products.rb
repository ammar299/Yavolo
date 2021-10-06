class CreateProducts < ActiveRecord::Migration[6.1]
  def change
    create_table :products do |t|
      t.string :title
      t.string :handle
      t.text :description
      t.text :keywords
      t.string :sku
      t.string :ean
      t.string :yan
      t.string :brand
      t.integer :condition
      t.integer :status
      t.integer :stock
      t.decimal :price, precision: 8, scale: 2
      t.decimal :discount, precision: 8, scale: 2
      t.integer :discount_unit
      t.boolean :yavolo_enabled, default: false
      t.string :width
      t.string :depth
      t.string :height
      t.string :colour
      t.string :material
      t.datetime :published_at
      t.bigint  :owner_id
      t.string  :owner_type
      t.timestamps
    end

    add_index :products, :title
    add_index :products, :sku, unique: true
    add_index :products, :ean, unique: true
    add_index :products, :yan, unique: true
    add_index :products, :price
    add_index :products, :brand
    add_index :products, :status
    add_index :products, [:owner_type, :owner_id]
  end
end
