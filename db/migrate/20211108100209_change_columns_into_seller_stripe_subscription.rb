class ChangeColumnsIntoSellerStripeSubscription < ActiveRecord::Migration[6.1]
  def change
    add_column :seller_stripe_subscriptions, :subscription_schedule_id, :string
  end
end
