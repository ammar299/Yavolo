class CreateFavProducts < ActiveRecord::Migration[6.1]
  def change
    create_table :fav_products do |t|
      t.references :wishlist, foreign_key: true
      t.references :product, foreign_key: true
      t.timestamps
    end
  end
end
