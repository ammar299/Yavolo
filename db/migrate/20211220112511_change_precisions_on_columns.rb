class ChangePrecisionsOnColumns < ActiveRecord::Migration[6.1]
  def change
    change_column :yavolo_bundles, :price, :decimal, precision: 10, scale: 2
    change_column :yavolo_bundle_products, :price, :decimal, precision: 9, scale: 2
  end
end
