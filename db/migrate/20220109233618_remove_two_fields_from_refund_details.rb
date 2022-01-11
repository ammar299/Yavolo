class RemoveTwoFieldsFromRefundDetails < ActiveRecord::Migration[6.1]
  def change
    remove_column :refund_details, :product_id
    remove_column :refund_details, :amount_paid
  end
end
