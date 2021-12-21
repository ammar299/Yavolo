class Order < ApplicationRecord
  belongs_to :buyer, optional: true
  include RansackObject
  has_many :line_items, dependent: :destroy
  has_one :order_detail, dependent: :destroy
  has_one :shipping_address, dependent: :destroy
  has_one :billing_address, dependent: :destroy
  has_one :payment_mode, dependent: :destroy
  has_one :refund, dependent: :destroy
  has_many :refund_details, dependent: :destroy
  has_many :refund_messages, dependent: :destroy
  belongs_to :buyer_payment_method, optional: true

  accepts_nested_attributes_for :order_detail, :line_items, :shipping_address, :billing_address

  enum order_type: { 
    abundent_checkout: 0,
    paid_order: 1,
 }

  scope :seller_orders, ->(owner) { includes(line_items: [:product]).where(line_items: {products: {owner_id: owner.id}}) }

  after_create :assign_unique_order_number

  def assign_unique_order_number
    self.update(order_number: "YAVO#{rand(100000..999999)}")
  end

  ransacker :idfilter do
    Arel.sql("to_char(\"#{table_name}\".\"id\", '99999999')")
  end
end
