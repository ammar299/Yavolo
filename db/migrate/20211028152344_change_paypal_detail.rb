class ChangePaypalDetail < ActiveRecord::Migration[6.1]
  def change
    rename_column :paypal_details, :seller_tracking_id, :seller_action_url
  end
end
