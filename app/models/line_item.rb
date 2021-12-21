class LineItem < ApplicationRecord
  belongs_to :order
  belongs_to :product

  scope :product_owners_collection, -> { map { |line_item| line_item.product&.owner }.uniq }
end
