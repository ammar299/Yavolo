class AddFieldsInSeller < ActiveRecord::Migration[6.1]
  def change
    add_column :sellers, :account_status, :integer, default: 0
    add_column :sellers, :listing_status, :integer, default: 0
    add_column :sellers, :contact_email, :string, default: "", null: false
    add_column :sellers, :contact_name, :string, default: "", null: false
    add_column :sellers, :subscription_type, :integer, default: 0
  end
end
