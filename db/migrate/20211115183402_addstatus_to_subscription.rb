class AddstatusToSubscription < ActiveRecord::Migration[6.1]
  def change
    add_column :seller_stripe_subscriptions, :status_set_by_admin, :string
  end
end
