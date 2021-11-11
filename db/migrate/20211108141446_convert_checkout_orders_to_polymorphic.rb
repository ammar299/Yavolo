class ConvertCheckoutOrdersToPolymorphic < ActiveRecord::Migration[6.1]
  def change
    #Ex:- add_column("admin_users", "username", :string, :limit =>25, :after => "email")
    add_column :checkout_orders, :checkoutable_id, :bigint
    add_column :checkout_orders, :checkoutable_type, :string

    #Ex:- add_index("admin_users", "username")
    add_index :checkout_orders, :checkoutable_id
    add_index :checkout_orders, :checkoutable_type
  end
end
