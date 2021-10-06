class CreateEbayDetails < ActiveRecord::Migration[6.1]
  def change
    create_table :ebay_details do |t|
      t.decimal :lifetime_sales, precision: 10, scale: 2
      t.decimal :thirty_day_sales, precision: 10, scale: 2
      t.decimal :price, precision: 8, scale: 2
      t.decimal :thirty_day_revenue, precision: 10, scale: 2
      t.string :mpn_number
      t.references :product, index: true
      t.timestamps
    end
  end
end
