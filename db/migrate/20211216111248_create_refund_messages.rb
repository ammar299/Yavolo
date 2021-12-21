class CreateRefundMessages < ActiveRecord::Migration[6.1]
  def change
    create_table :refund_messages do |t|
      t.references :order, foreign_key: true
      t.references :refund, foreign_key: true
      t.references :buyer, foreign_key: true
      t.text :buyer_message
      t.references :seller, foreign_key: true
      t.text :seller_message
      t.timestamps
    end
  end
end
