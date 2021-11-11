class DropUnusedModels < ActiveRecord::Migration[6.1]
  def change
    remove_column :shipping_addresses, :checkout_orders_id
    remove_column :billing_addresses, :checkout_orders_id
    
    drop_table :checkout_orders
  end
end
