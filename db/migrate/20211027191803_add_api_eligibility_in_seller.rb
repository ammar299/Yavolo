class AddApiEligibilityInSeller < ActiveRecord::Migration[6.1]
  def change
    add_column :sellers, :eligible_to_create_api, :boolean, default: false
    #Ex:- add_column("admin_users", "username", :string, :limit =>25, :after => "email")
  end
end
