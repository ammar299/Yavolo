class CreateRefunds < ActiveRecord::Migration[6.1]
  def change
    create_table :refunds do |t|
      t.references :order, foreign_key: true
      t.integer :refund_reason
      t.decimal :total_paid
      t.decimal :total_refund
      t.timestamps
    end
  end
end
