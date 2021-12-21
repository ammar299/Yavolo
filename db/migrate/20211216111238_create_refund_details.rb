class CreateRefundDetails < ActiveRecord::Migration[6.1]
  def change
    create_table :refund_details do |t|
      t.references :order, foreign_key: true
      t.references :refund, foreign_key: true
      t.references :product, foreign_key: true
      t.decimal :amount_paid
      t.decimal :amount_refund
      t.timestamps
    end
  end
end
