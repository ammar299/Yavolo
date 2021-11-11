class AddFieldsInLineItems < ActiveRecord::Migration[6.1]
  def change
    add_column :line_items, :price, :decimal
    add_column :line_items, :added_on, :string
    add_column :line_items, :quantity, :integer
    #Ex:- :default =>''
    #Ex:- add_column("admin_users", "username", :string, :limit =>25, :after => "email")
  end
end
