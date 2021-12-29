class AddColumnToSubscription < ActiveRecord::Migration[6.1]
  def change
    add_column :subscriptions, :subscription_months, :integer
    add_column :subscriptions, :rolling_subscription, :string
    add_column :subscriptions, :default_subscription, :boolean, default: false
    rename_column :subscriptions, :subscription_types,:subscription_type
  end
end
