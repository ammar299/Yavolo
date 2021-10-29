class DropPaymentsTable < ActiveRecord::Migration[6.1]
  def change
    drop_table :payments
    create_table :orders do |t|
      t.boolean :paid, :default => false
      t.string :token
      t.integer :price
      t.timestamps
    end
  end
end
