class YavoloBundle < ApplicationRecord
  has_many :yavolo_bundle_products, dependent: :destroy
  has_many :products, through: :yavolo_bundle_products
  has_one :seo_content, dependent: :destroy, as: :seo_content_able
  has_one :google_shopping, dependent: :destroy, as: :google_shopping_able

  enum status: {draft: 0, pending: 1, disbundled: 2, live: 3}

  accepts_nested_attributes_for :seo_content, :google_shopping, :yavolo_bundle_products

  attr_accessor :check_for_seo_content_uniqueness
end
