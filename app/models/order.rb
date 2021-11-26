class Order < ApplicationRecord
  belongs_to :buyer
  include RansackObject
  has_many :line_items, dependent: :destroy
  has_one :order_detail, dependent: :destroy
  has_one :shipping_address, dependent: :destroy
  has_one :billing_address, dependent: :destroy
  has_one :payment_mode, dependent: :destroy
  belongs_to :buyer_payment_method, optional: true

  accepts_nested_attributes_for :order_detail, :line_items, :shipping_address, :billing_address

  enum order_type: { 
    abundent_checkout: 0,
    paid_order: 1,
 }
end
