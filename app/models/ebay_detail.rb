class EbayDetail < ApplicationRecord
  belongs_to :product
  # validates :lifetime_sales, :thirty_day_sales, :price, :thirty_day_revenue, :mpn_number, presence: true
end
