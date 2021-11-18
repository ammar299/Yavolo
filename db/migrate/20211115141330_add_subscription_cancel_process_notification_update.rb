class AddSubscriptionCancelProcessNotificationUpdate < ActiveRecord::Migration[6.1]
  def change
    remove_column :seller_stripe_subscriptions, :seller_requested_cancelation
    add_column :seller_stripe_subscriptions, :seller_requested_cancelation, :boolean , default: false
  end
end
