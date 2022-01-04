class LineItem < ApplicationRecord
  belongs_to :order
  belongs_to :product

  scope :product_owners_collection, -> { map { |line_item| line_item.product&.owner }.uniq }

  enum transfer_status: {
    pending: 0,
    paid: 1,
    refunded: 2,
    canceled: 3,
    partial_refunded: 4
  }

  enum commission_status: {
    not_refunded: 0,
    commission_refunded: 1
  }

  scope :seller_own_order_line_items, ->(owner) {
    owner.class.name == "Seller" ? joins(:product).where(products: { owner_id: owner.id }) : all
  }
end
