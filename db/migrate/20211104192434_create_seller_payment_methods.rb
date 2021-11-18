class CreateSellerPaymentMethods < ActiveRecord::Migration[6.1]
  def change
    create_table :seller_payment_methods do |t|
      t.string :stripe_token
      t.string :object
      t.string :type
      t.string :card_id
      t.string :brand
      t.string :country
      t.string :cvc_check
      t.integer :exp_month
      t.integer :exp_year
      t.string :fingerprint
      t.string :funding
      t.string :last4digit
      t.string :name
      t.string :tokenization_method
      t.string :livemode
      t.boolean :used
      t.references :seller, null: false, foreign_key: true
      t.timestamps
    end
  end
end
