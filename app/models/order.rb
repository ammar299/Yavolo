class Order < ApplicationRecord

  include RansackObject

  belongs_to :buyer, optional: true
  has_many :line_items, dependent: :destroy
  has_one :order_detail, dependent: :destroy
  has_one :shipping_address, dependent: :destroy
  has_one :billing_address, dependent: :destroy
  has_one :payment_mode, dependent: :destroy
  has_many :refunds, dependent: :destroy
  has_many :refund_details, dependent: :destroy
  has_many :refund_modes, dependent: :destroy
  has_many :reversal_modes, dependent: :destroy
  belongs_to :buyer_payment_method, optional: true

  accepts_nested_attributes_for :order_detail, :line_items, :shipping_address, :billing_address

  enum order_type: { 
    abundent_checkout: 0,
    paid_order: 1,
 }

  default_scope -> { order(created_at: :desc) }
  scope :seller_orders, ->(owner) { includes(line_items: [:product]).where(line_items: {products: {owner_id: owner.id}}) }
  scope :paid_orders_listing, -> { where(order_type: 'paid_order') }
  scope :search_product_a_to_z, ->(q) { includes(line_items: :product).where("product.title LIKE '%#{q}%'").order('product.title ASC') }
  scope :search_product_z_to_a, ->(q) { includes(line_items: :product).where("product.title LIKE '%#{q}%'").order('product.title DESC') }

  after_create :assign_unique_order_number
  after_create :billing_address_is_same_as_shipping_address

  def self.ransackable_scopes(auth_object = nil)
    %i(search_product_a_to_z search_product_z_to_a)
  end

  def assign_unique_order_number
    self.update(order_number: "YAVO#{rand(100000..999999)}")
  end

  def billing_address_is_same_as_shipping_address
    if self.billing_address_is_shipping_address
      self.billing_address.update(self.shipping_address.attributes)
    end
  end

  ransacker :idfilter do
    Arel.sql("to_char(\"#{table_name}\".\"id\", '99999999')")
  end
end
