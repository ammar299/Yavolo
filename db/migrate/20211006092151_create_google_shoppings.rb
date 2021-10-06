class CreateGoogleShoppings < ActiveRecord::Migration[6.1]
  def change
    create_table :google_shoppings do |t|
      t.string :title
      t.decimal :price, precision: 8, scale: 2
      t.string :category
      t.string :campaign_category
      t.text :description
      t.references :product, index: true
      t.boolean :exclude_from_google_feed, default: false
      t.timestamps
    end
  end
end
