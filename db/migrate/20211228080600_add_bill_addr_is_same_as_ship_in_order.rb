class AddBillAddrIsSameAsShipInOrder < ActiveRecord::Migration[6.1]
  def change
    add_column :orders, :billing_address_is_shipping_address, :boolean, default: false
  end
end
