class AddDeveloperNameInSellerApi < ActiveRecord::Migration[6.1]
  def change
    #Ex:- add_column("admin_users", "username", :string, :limit =>25, :after => "email")
    add_column :seller_apis, :developer_name, :string
    add_column :seller_apis, :developer_id, :string
    add_column :seller_apis, :app_name, :string
    add_column :seller_apis, :expiry_date, :datetime
  end
end
