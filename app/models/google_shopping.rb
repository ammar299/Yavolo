class GoogleShopping < ApplicationRecord
  include DuplicateRecord

  belongs_to :google_shopping_able, polymorphic: true
  # validates :title, :price, :category, :campaign_category, :description, presence: true
end
