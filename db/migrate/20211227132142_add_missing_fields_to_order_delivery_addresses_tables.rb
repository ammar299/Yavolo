class AddMissingFieldsToOrderDeliveryAddressesTables < ActiveRecord::Migration[6.1]
  def up
    add_column :billing_addresses, :first_name, :string
    add_column :billing_addresses, :last_name, :string
    add_column :billing_addresses, :company_name, :string
    add_column :shipping_addresses, :first_name, :string
    add_column :shipping_addresses, :last_name, :string
    add_column :shipping_addresses, :company_name, :string
  end
end
