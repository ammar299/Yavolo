class CreateWishlist < ActiveRecord::Migration[6.1]
  def change
    create_table :wishlists do |t|
      t.references :buyer, foreign_key: true
      t.timestamps
    end
  end
end
