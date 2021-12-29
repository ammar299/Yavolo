class DropSubscriptionLog < ActiveRecord::Migration[6.1]
  def change
    drop_table :subscription_logs
  end
end
