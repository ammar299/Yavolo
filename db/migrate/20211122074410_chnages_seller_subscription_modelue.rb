class ChnagesSellerSubscriptionModelue < ActiveRecord::Migration[6.1]
  def change
    add_column :seller_stripe_subscriptions,:plan_id ,:string
  end
end
