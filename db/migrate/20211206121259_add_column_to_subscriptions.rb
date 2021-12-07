class AddColumnToSubscriptions < ActiveRecord::Migration[6.1]
  def change
    add_column :seller_stripe_subscriptions , :reason, :string 
  end
end
