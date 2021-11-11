class AddOrderReferenceInLineItem < ActiveRecord::Migration[6.1]
  def change
    add_reference :line_items, :orders
    add_reference :line_items, :products
  end
end
