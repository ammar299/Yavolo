class AddOnmiAuthFieldsInSeller < ActiveRecord::Migration[6.1]
  def change
    add_column :sellers, :provider, :string
    add_column :sellers, :uid, :string
  end
end
