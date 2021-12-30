class ChangeSellerSubscriptionType < ActiveRecord::Migration[6.1]
  def change
    change_column :sellers, :subscription_type ,:string
  end
end
