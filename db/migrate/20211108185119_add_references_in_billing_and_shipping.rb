class AddReferencesInBillingAndShipping < ActiveRecord::Migration[6.1]
  def change
    add_reference :billing_addresses, :checkout_orders
    add_reference :shipping_addresses, :checkout_orders
  end
end
