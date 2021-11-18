class RemoveColumnsFromStripeCustomers < ActiveRecord::Migration[6.1]
  def change
    remove_column :stripe_customers, :object
    remove_column :stripe_customers, :currency
    remove_column :stripe_customers, :delinquent
    remove_column :stripe_customers, :description
    remove_column :stripe_customers, :invoice_prefix
    remove_column :stripe_customers, :livemode
    remove_column :stripe_customers, :tax_exempt
    remove_column :stripe_customers, :next_invoice_sequence
    remove_column :stripe_customers, :phone
   
    remove_column :seller_payment_methods, :object
    remove_column :seller_payment_methods, :card_id
    remove_column :seller_payment_methods, :payment_method_type
    remove_column :seller_payment_methods, :brand
    remove_column :seller_payment_methods, :country
    remove_column :seller_payment_methods, :cvc_check
    remove_column :seller_payment_methods, :exp_month
    remove_column :seller_payment_methods, :exp_year
    remove_column :seller_payment_methods, :fingerprint
    remove_column :seller_payment_methods, :funding
    remove_column :seller_payment_methods, :last4digit
    remove_column :seller_payment_methods, :name
    remove_column :seller_payment_methods, :tokenization_method
    remove_column :seller_payment_methods, :livemode
    remove_column :seller_payment_methods, :used
  end
end
