class AddHolidayModeLockedInSeller < ActiveRecord::Migration[6.1]
  def change
    add_column :sellers, :holiday_mode, :boolean, default: false
    add_column :sellers, :is_locked, :boolean, default: false
    #Ex:- add_column("admin_users", "username", :string, :limit =>25, :after => "email")
  end
end
