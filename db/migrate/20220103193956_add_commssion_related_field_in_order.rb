class AddCommssionRelatedFieldInOrder < ActiveRecord::Migration[6.1]
  def change
    add_column :orders, :commission, :decimal
    add_column :orders, :remaining_price, :decimal
    add_column :orders, :refunded_amount, :decimal
  end
end
