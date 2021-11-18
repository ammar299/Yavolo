class CreateSubscriptionPlans < ActiveRecord::Migration[6.1]
  def change
    create_table :subscription_plans do |t|
      t.string :stripe_subscription_id
      t.string :name
      t.string :status
      t.string :description
      t.timestamps
    end
  end
end
