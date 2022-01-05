class DropTableRefundMessages < ActiveRecord::Migration[6.1]
  def change
    drop_table :refund_messages
  end
end
