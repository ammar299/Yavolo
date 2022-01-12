class Refund < ApplicationRecord

  enum refund_reason: {
    "item_never_arrived_with_the_customer": 0,
    "item_was_damaged": 1,
    "customer_was_not_happy_with_item": 2,
    "customer_was_not_happy_with_service": 3,
    "customer_has_returned_item": 4,
    "customer_exchange": 5,
    "item_was_defective": 6,
    "item_was_missing_part": 7,
    "late_delivery": 8,
    "refused_delivery": 9,
    "no_inventory": 10,
    "late_dispatch": 11,
    "undeliverable_shipping_address": 12,
    "product_not_as_described": 13,
    "incorrect_time": 14,
    "general_adjustment": 15
  }

  belongs_to :order
  has_many :refund_details, dependent: :destroy
  accepts_nested_attributes_for :refund_details, reject_if: proc { |attribute| attribute['amount_refund'].blank? }
  has_many :refund_modes, dependent: :destroy
  has_many :reversal_modes, dependent: :destroy

end
