class CreateYavoloBundleProducts < ActiveRecord::Migration[6.1]
  def change
    create_table :yavolo_bundle_products do |t|
      t.decimal "price", precision: 8, scale: 2
      t.references :product, null: false, foreign_key: true
      t.references :yavolo_bundle, null: false, foreign_key: true

      t.timestamps
    end
  end
end
