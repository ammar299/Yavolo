class CreateSellerStripeSubscription < ActiveRecord::Migration[6.1]
  def change
    create_table :seller_stripe_subscriptions do |t|
      t.string :subscription_stripe_id
      t.string :plan_name
      t.string :status
      t.string :product_id
      t.string :object
      t.string :application_fee_percent
      t.boolean :automatic_tax_status
      t.bigint :billing_cycle_anchor
      t.datetime :cancel_at
      t.boolean :cancel_at_period_end
      t.datetime :canceled_at
      t.string :collection_method
      t.datetime :current_period_end
      t.datetime :current_period_start
      t.string :customer
      t.string :default_payment_method
      t.float :default_tax_rates
      t.integer :recurring_interval_count
      t.string :recurring_interval
      t.string :recurring_usage_type
      t.string :tiers_mode
      t.string :type
      t.references :seller, null: false, foreign_key: true
      t.timestamps
    end
  end
end
