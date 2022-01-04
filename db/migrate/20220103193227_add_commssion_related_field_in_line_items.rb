class AddCommssionRelatedFieldInLineItems < ActiveRecord::Migration[6.1]
  def change
    add_column :line_items, :commission, :decimal
    add_column :line_items, :remaining_price, :decimal
    add_column :line_items, :refunded_amount, :decimal
    add_column :line_items, :commission_status, :integer, default: 0
  end
end
