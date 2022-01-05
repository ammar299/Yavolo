class AddLineItemIdToRefundDetails < ActiveRecord::Migration[6.1]
  def change
    add_reference :refund_details, :line_item
  end
end
