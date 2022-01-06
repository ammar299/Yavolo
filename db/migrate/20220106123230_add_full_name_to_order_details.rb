class AddFullNameToOrderDetails < ActiveRecord::Migration[6.1]
  def change
    add_column :order_details, :full_name, :string
    add_column :sellers, :full_name, :string
  end
end
