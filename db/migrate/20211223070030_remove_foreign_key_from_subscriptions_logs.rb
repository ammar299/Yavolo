class RemoveForeignKeyFromSubscriptionsLogs < ActiveRecord::Migration[6.1]
  def change
    remove_reference :subscription_logs, :seller, index: true, foreign_key: true
    add_reference :subscription_logs, :seller_stripe_subscription, foreign_key: true
  end
end
