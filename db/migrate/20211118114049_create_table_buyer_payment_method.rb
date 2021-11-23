class CreateTableBuyerPaymentMethod < ActiveRecord::Migration[6.1]
  def change
    create_table :buyer_payment_methods do |t|
      t.string :stripe_token
      t.string :last_digits
      t.string :card_holder_name
      t.string :card_id

      t.references :buyer, index: true
      t.timestamps
    end
  end
end
