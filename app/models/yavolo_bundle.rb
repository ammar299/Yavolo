class YavoloBundle < ApplicationRecord

  # Yavolo bundles handle will start with text yavolobundle followed by 4 digits, then underscore, then bundle title
  SLUG_REGEX_PATTERN = "\\Ayavolobundle\\d{4}_"

  extend FriendlyId
  friendly_id :slug_for_bundle

  has_many :yavolo_bundle_products, dependent: :destroy
  has_many :products, -> { order('yavolo_bundle_products.id asc') }, through: :yavolo_bundle_products
  has_one :seo_content, dependent: :destroy, as: :seo_content_able
  has_one :google_shopping, dependent: :destroy, as: :google_shopping_able
  has_one :main_image, -> { where(is_featured: true) }, as: :imageable, dependent: :destroy, class_name: 'Picture'
  has_many :pictures, -> { where(is_featured: false) }, as: :imageable, dependent: :destroy
  alias_attribute :images, :pictures

  enum status: {draft: 0, pending: 1, disbundled: 2, live: 3}, _prefix: true
  enum previous_status: {draft: 0, pending: 1, disbundled: 2, live: 3}, _prefix: true

  accepts_nested_attributes_for :seo_content, :google_shopping, :yavolo_bundle_products, :main_image
  accepts_nested_attributes_for :pictures, allow_destroy: true

  attr_accessor :check_for_seo_content_uniqueness

  validates_presence_of :title, :description, :category_id, :quantity
  validates :max_stock_limit, :stock_limit, :price, :regular_total, :yavolo_total, presence: true, inclusion: {in: 0..MAX_STOCK_VALUE, message: "value should be between 0 and #{MAX_STOCK_VALUE}"}

  before_save :assign_yan_to_bundle
  before_save :assign_value_to_previous_status

  def self.disbundle_bundle_when_seller_deactivated(seller)
    yavolo_bundles_ids = YavoloBundleProduct.where(product_id: seller.products.ids).pluck(:yavolo_bundle_id)
    YavoloBundle.where(id: yavolo_bundles_ids).each {|yb| yb.update(status: :disbundled)}
  end

  def self.disbundle_bundle_when_product_deactivated(product)
    yavolo_bundles_ids = YavoloBundleProduct.where(product_id: product.id).pluck(:yavolo_bundle_id)
    YavoloBundle.where(id: yavolo_bundles_ids).each {|yb| yb.update(status: :disbundled)}
  end

  def self.reassign_status_to_bundle_when_seller_activated(seller)
    yavolo_bundles_ids = YavoloBundleProduct.where(product_id: seller.products.ids).pluck(:yavolo_bundle_id)
    self.reassign_previous_status_to_bundle(yavolo_bundles_ids)
  end

  def self.reassign_status_to_bundle_when_product_activated(product)
    yavolo_bundles_ids = YavoloBundleProduct.where(product_id: product.id).pluck(:yavolo_bundle_id)
    self.reassign_previous_status_to_bundle(yavolo_bundles_ids)
  end

  def self.reassign_previous_status_to_bundle(yavolo_bundles_ids)
    YavoloBundle.includes(yavolo_bundle_products: :product).where(id: yavolo_bundles_ids).each do |yb|
      if yb.products.inactive.not_yavolo_enabled.size.zero?
        yb.update(status: yb.previous_status)
      end
    end
  end

  private

  def assign_yan_to_bundle
    return if self.yan.present?
    loop do
      self.yan = "YB" + SecureRandom.send('choose', [*'0'..'9'], 11)
      break unless self.class.exists?(yan: yan)
    end
  end

  def slug_for_bundle
    random_digits = SecureRandom.send('choose', [*'0'..'9'], 4)
    "yavolobundle#{random_digits}_#{title}"
  end

  def assign_value_to_previous_status
    return unless self.status_changed?
    self.previous_status = self.status_was&.to_sym
  end

end
