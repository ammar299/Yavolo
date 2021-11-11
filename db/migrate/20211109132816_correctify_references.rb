class CorrectifyReferences < ActiveRecord::Migration[6.1]
  def change
    # remove wrong references from line item
    remove_reference :line_items, :orders
    remove_reference :line_items, :products
    # add correct references in line item
    add_reference :line_items, :order
    add_reference :line_items, :product
    # remove wrong references from order details
    remove_reference :order_details, :orders
    # add correct references in order details
    add_reference :order_details, :order
    # add correct references in billing and shipping address
    add_reference :billing_addresses, :order
    add_reference :shipping_addresses, :order
  end
end
