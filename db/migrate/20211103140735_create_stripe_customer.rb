class CreateStripeCustomer < ActiveRecord::Migration[6.1]
  def change
    create_table :stripe_customers do |t|
      t.string :customer_id
      t.string :object
      t.string :currency
      t.string :delinquent
      t.string :description
      t.string :invoice_prefix
      t.string :livemode
      t.string :tax_exempt
      t.integer :next_invoice_sequence
      t.bigint :phone
      t.string :email
      t.references :seller, null: false, foreign_key: true
      t.timestamps
    end
  end
end
