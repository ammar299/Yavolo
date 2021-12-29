class AddColumnsToSubscriptions < ActiveRecord::Migration[6.1]
  def change
    add_column :subscriptions, :plan_id, :string
    add_column :subscriptions, :plan_name_id, :string
  end
end
