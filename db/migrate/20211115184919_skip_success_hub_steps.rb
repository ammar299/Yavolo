class SkipSuccessHubSteps < ActiveRecord::Migration[6.1]
  def change
    add_column :sellers, :skip_success_hub_steps, :boolean, default: false
    #Ex:- add_column("admin_users", "username", :string, :limit =>25, :after => "email")
  end
end
