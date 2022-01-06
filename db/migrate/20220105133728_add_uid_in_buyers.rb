class AddUidInBuyers < ActiveRecord::Migration[6.1]
  def change
    add_column :buyers, :provider, :string
    add_column :buyers, :uid, :string
  end
end
