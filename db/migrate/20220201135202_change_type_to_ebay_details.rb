class ChangeTypeToEbayDetails < ActiveRecord::Migration[6.1]
  def change
    change_column :ebay_details, :lifetime_sales, :integer
    change_column :ebay_details, :thirty_day_sales, :integer
  end
end
