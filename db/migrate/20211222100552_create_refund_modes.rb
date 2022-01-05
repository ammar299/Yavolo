class CreateRefundModes < ActiveRecord::Migration[6.1]
  def change
    create_table :refund_modes do |t|
      t.references :order, foreign_key: true
      t.references :refund, foreign_key: true
      t.references :buyer, foreign_key: true
      t.references :line_item, foreign_key: true
      t.string :response_refund_id
      t.string :charge_id
      t.decimal :amount_refund
      t.integer :refund_through
      t.string :status
      t.timestamps
    end
  end
end
