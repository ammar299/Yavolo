class AddOrderReferenceInOrderDetail < ActiveRecord::Migration[6.1]
  def change
    add_reference :order_details, :orders
  end
end
