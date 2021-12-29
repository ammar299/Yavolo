class DropTableSubscriptionPlanAndChangeSubscriptionName < ActiveRecord::Migration[6.1]
  def change
    drop_table :subscription_plans
    rename_table :subscriptions, :subscription_plans
  end
end
