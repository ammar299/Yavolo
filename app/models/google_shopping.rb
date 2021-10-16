class GoogleShopping < ApplicationRecord
  belongs_to :product
  # validates :title, :price, :category, :campaign_category, :description, presence: true
end
