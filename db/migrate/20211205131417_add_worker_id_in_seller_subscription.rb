class AddWorkerIdInSellerSubscription < ActiveRecord::Migration[6.1]
  def change
    add_column :seller_stripe_subscriptions , :associated_worker, :string 
  end
end
