class Wishlist < ApplicationRecord
  belongs_to :buyer
  has_many :fav_products
  has_many :products, through: :fav_products
end
