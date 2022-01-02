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

  accepts_nested_attributes_for :seo_content, :google_shopping, :yavolo_bundle_products, :main_image
  accepts_nested_attributes_for :pictures, allow_destroy: true

  attr_accessor :check_for_seo_content_uniqueness

  validates_presence_of :title, :description, :category_id, :quantity
  validates :max_stock_limit, :stock_limit, :price, :regular_total, :yavolo_total, presence: true, inclusion: {in: 0..MAX_STOCK_VALUE, message: "value should be between 0 and #{MAX_STOCK_VALUE}"}

  before_save :assign_yan_to_bundle

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

end
