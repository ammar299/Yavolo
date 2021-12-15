class AddOrderNumberToOrders < ActiveRecord::Migration[6.1]
  def change
    add_column :orders, :order_number, :string
  end
end
