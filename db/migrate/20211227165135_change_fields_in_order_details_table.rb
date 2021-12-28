class ChangeFieldsInOrderDetailsTable < ActiveRecord::Migration[6.1]
  def change
    rename_column :order_details, :name, :first_name
    rename_column :order_details, :contact_number, :phone_number
    add_column :order_details, :last_name, :string
  end
end
