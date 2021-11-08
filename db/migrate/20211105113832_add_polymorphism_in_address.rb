class AddPolymorphismInAddress < ActiveRecord::Migration[6.1]
  def change
    #Ex:- add_column("admin_users", "username", :string, :limit =>25, :after => "email")
    add_column :addresses, :addressable_id, :bigint
    add_column :addresses, :addressable_type, :string

    #Ex:- add_index("admin_users", "username")
    add_index :addresses, :addressable_id
    add_index :addresses, :addressable_type
  end
end
