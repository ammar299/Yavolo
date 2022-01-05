class CreateReversalModes < ActiveRecord::Migration[6.1]
  def change
    create_table :reversal_modes do |t|
      t.references :order, foreign_key: true
      t.references :refund, foreign_key: true
      t.references :seller, foreign_key: true
      t.references :line_item, foreign_key: true
      t.string :transfer_id
      t.string :transfer_reversal_id
      t.integer :reversal_through
      t.decimal :amount_reversed
      t.timestamps
    end
  end
end
