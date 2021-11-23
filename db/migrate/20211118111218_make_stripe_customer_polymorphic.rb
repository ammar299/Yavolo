class MakeStripeCustomerPolymorphic < ActiveRecord::Migration[6.1]
  def change
    add_column :stripe_customers, :stripe_customerable_id, :bigint
    add_column :stripe_customers, :stripe_customerable_type, :string
    #Ex:- add_column("admin_users", "username", :string, :limit =>25, :after => "email")

    #Ex:- add_index("admin_users", "username")
    add_index :stripe_customers, :stripe_customerable_id
    add_index :stripe_customers, :stripe_customerable_type


    StripeCustomer.update_all("stripe_customerable_id=seller_id,stripe_customerable_type='Seller'")

    remove_column :stripe_customers, :seller_id
  end
end
