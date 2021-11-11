class RenameCheckoutDetailsModel < ActiveRecord::Migration[6.1]
  def change
    rename_table :checkout_details, :checkout_orders
  end
end
