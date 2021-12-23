class YavoloBundle < ApplicationRecord
  has_many :yavolo_bundle_products, dependent: :destroy
  has_many :products, through: :yavolo_bundle_products
  has_one :seo_content, dependent: :destroy, as: :seo_content_able
  has_one :google_shopping, dependent: :destroy, as: :google_shopping_able
  has_one :main_image, -> { where(is_featured: true) },as: :imageable, dependent: :destroy, class_name: 'Picture'
  has_many :pictures,-> { where(is_featured: false) }, as: :imageable, dependent: :destroy
  alias_attribute  :images, :pictures

  enum status: {draft: 0, pending: 1, disbundled: 2, live: 3}, _prefix: true

  accepts_nested_attributes_for :seo_content, :google_shopping, :yavolo_bundle_products, :main_image
  accepts_nested_attributes_for :pictures, allow_destroy: true

  attr_accessor :check_for_seo_content_uniqueness

  validates_presence_of :title, :description, :category_id, :price, :quantity

  before_save :assign_yan_to_bundle

  def export_yavolos(yavolos)
    yavolos = yavolos&.split(",")
    CSV.generate(headers: true) do |csv|
      max_bundled_products ||= get_max_product_number(yavolos)
      csv_headers = []
      csv_headers << csv_headers_yavolo
      csv_headers << csv_headers_yavolo_products(max_bundled_products)
      csv << csv_headers.flatten
      yavolos.each do |yavolo|
        yavolo = YavoloBundle.where(id: yavolo.to_i).last
        if yavolo.present?
          csv << create_row_in_csv(max_bundled_products,yavolo)
        end
      end
    end
  end

  def create_row_in_csv(max,yavolo)
    csv_row = []
    csv_row << [yavolo.max_stock_limit, yavolo.stock_limit, yavolo.price, 
      yavolo.seo_content&.title , yavolo.seo_content&.url , yavolo.seo_content&.keywords,  yavolo.seo_content&.description,

      yavolo.google_shopping&.title,  yavolo.google_shopping&.price,  yavolo.google_shopping&.category,  yavolo.google_shopping&.campaign_category,
      yavolo.google_shopping&.description,  yavolo.google_shopping&.exclude_from_google_feed,  yavolo.title,  get_category(yavolo.category_id),  yavolo.description,
    ]
    csv_row << get_product_values(max,yavolo)
    csv_row.flatten
  end

  def get_product_values(max,yavolo)
    csv_row = []
    (0...max).each do |i|
      next unless yavolo.products[i].present?
      [:ean,:title,:width,:depth,:height,:colour,:material,:keywords,:description].each do |sym|
        csv_row << yavolo.products[i][sym]
      end
    end
    return csv_row
  end

  def get_max_product_number(yavolos)
    max_bundled_products = []
    yavolos&.each do |yavolo|
      max_bundled_products <<  YavoloBundle.where(id: yavolo.to_i)&.last&.products&.count
    end
    return max_bundled_products.max
  end

  def csv_headers_yavolo
    [
      "yavolo_stock_display_limit", "yavolo_stock_limit", "adjust_to_price", "meta_title", "url", "meta_keywords", "meta_description",
      "google_shopping_title", "google_shopping_price", "google_shopping_category", "google_shopping_campaign_category",
      "google_shopping_description", "google_exclude_from_google_feed", "yavolo_title", "yavolo_category", "yavolo_description",
    ]
  end

  def csv_headers_yavolo_products(max)
    csv_row = []
    (1..max).each do |i|
      [:ean,:title,:width,:depth,:height,:colour,:material,:keywords,:description].each do |sym|
        csv_row << "product_#{i}_#{sym}"
      end
    end
    return csv_row
  end

  def get_category(id)
    Category.find(id)&.category_name rescue ""
  end

  private

  def assign_yan_to_bundle
    return if self.yan.present?
    loop do
      self.yan = "YB" + SecureRandom.send('choose', [*'0'..'9'], 11)
      break unless self.class.exists?(yan: yan)
    end
  end

end
