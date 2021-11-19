class ChangeColumnNameInSellerStripeSubscription < ActiveRecord::Migration[6.1]
  def change
    add_column :seller_stripe_subscriptions, :schedule_date, :datetime
  end
end
