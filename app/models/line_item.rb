class LineItem < ApplicationRecord

  belongs_to :order
  belongs_to :product
  has_many :refund_details, dependent: :destroy
  has_many :refund_modes, dependent: :destroy
  has_many :reversal_modes, dependent: :destroy

  enum transfer_status: {
    pending: 0,
    paid: 1,
    refunded: 2,
    canceled: 3,
    partial_refunded: 4
  }

  enum commission_status: {
    not_refunded: 0,
    commission_refunded: 1,
    refunded_later: 2,
  }

  scope :product_owners_collection, -> { map { |line_item| line_item.product&.owner }.uniq }
  scope :user_own_order_line_items, ->(owner) { joins(:product).where(products: { owner_id: owner.id }) if owner.class.name == "Seller" }

  def self.net_refund_of(id)
    where(id: id).includes(:refund_details).sum("refund_details.amount_refund")
  end

  def self.net_paid_of(id)
    where(id: id).sum("quantity * price")
  end
end
