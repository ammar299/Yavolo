class AddDealsColumnInBuyer < ActiveRecord::Migration[6.1]
  def change
    add_column :buyers, :receive_deals_via_email, :boolean, default: false
  end
end
