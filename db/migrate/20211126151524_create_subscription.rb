class CreateSubscription < ActiveRecord::Migration[6.1]
  def change
    create_table :subscriptions do |t|
      t.string :subscription_name
      t.string :subscription_types
      t.float :price
      t.float :commission_excluding_vat
      t.timestamps
    end
  end
end
