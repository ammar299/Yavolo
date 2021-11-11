class AddFieldsInOrder < ActiveRecord::Migration[6.1]
  def change
    add_column :orders, :sub_total, :decimal
    add_column :orders, :discount_percentage, :integer
    add_column :orders, :discounted_price, :decimal
    #Ex:- add_column("admin_users", "username", :string, :limit =>25, :after => "email")
  end
end
