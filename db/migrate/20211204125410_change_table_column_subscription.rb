class ChangeTableColumnSubscription < ActiveRecord::Migration[6.1]
  def change
    remove_column :seller_stripe_subscriptions, :object
    remove_column :seller_stripe_subscriptions, :application_fee_percent
    remove_column :seller_stripe_subscriptions, :automatic_tax_status
    remove_column :seller_stripe_subscriptions, :billing_cycle_anchor
    remove_column :seller_stripe_subscriptions, :collection_method
    remove_column :seller_stripe_subscriptions, :default_payment_method
    remove_column :seller_stripe_subscriptions, :default_tax_rates
    remove_column :seller_stripe_subscriptions, :recurring_usage_type
    remove_column :seller_stripe_subscriptions, :tiers_mode
    remove_column :seller_stripe_subscriptions, :type
    add_column :seller_stripe_subscriptions, :cancel_after_next_payment_taken, :boolean, default: :false
    add_column :seller_stripe_subscriptions, :subscription_data, :string
  end
end
