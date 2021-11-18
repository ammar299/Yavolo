class AddSubscriptionCancelProcessNotification < ActiveRecord::Migration[6.1]
  def change
    add_column :seller_stripe_subscriptions, :seller_requested_cancelation, :boolean , default: true
  end
end
