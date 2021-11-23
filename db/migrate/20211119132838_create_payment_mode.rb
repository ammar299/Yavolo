class CreatePaymentMode < ActiveRecord::Migration[6.1]
  def change
    create_table :payment_modes do |t|
      t.integer :payment_through
      t.string :charge_id
      t.integer :amount
      t.string :return_url
      t.string :receipt_url

      t.references :buyer, index: true
      t.timestamps
    end
  end
end
