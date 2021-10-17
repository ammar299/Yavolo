class ChangeColumnToNull < ActiveRecord::Migration[6.1]
  def change
    remove_index :products, :sku, unique: true
    remove_index :products, :ean, unique: true
    remove_index :products, :yan, unique: true
    add_index :products, :sku
    add_index :products, :ean
    add_index :products, :yan
  end
end
