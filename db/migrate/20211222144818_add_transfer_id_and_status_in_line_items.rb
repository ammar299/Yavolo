class AddTransferIdAndStatusInLineItems < ActiveRecord::Migration[6.1]
  def change
    add_column :line_items, :transfer_id, :string
    add_column :line_items, :transfer_status, :integer
  end
end
