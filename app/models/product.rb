class Product < ApplicationRecord
    extend FriendlyId
    friendly_id :title

    enum condition: { brand_new: 0, refurbished: 1 }
    enum status: { draft: 0, active: 1, inactive: 2, pending: 3, disapproved: 4 }
    enum discount_unit:{ percentage: 0, amount: 1 }

    has_one :seo_content, dependent: :destroy
    has_one :ebay_detail, dependent: :destroy
    has_one :google_shopping, dependent: :destroy
    has_one :assigned_category, dependent: :destroy
    has_one :category, through: :assigned_category, dependent: :destroy


    has_many :pictures, as: :imageable, dependent: :destroy
    alias_attribute  :images, :pictures

    belongs_to :owner, polymorphic: true
    belongs_to :delivery_option

    accepts_nested_attributes_for :seo_content, :ebay_detail, :google_shopping, :assigned_category
    accepts_nested_attributes_for :pictures, allow_destroy: true

    validates :sku, uniqueness: true, if: Proc.new{|p| p.sku.present? }
    validates :ean, uniqueness: true, if: Proc.new{|p| p.ean.present? }
    validates :yan, uniqueness: true, if: Proc.new{|p| p.yan.present? }
    validates :title, :condition, :description, :keywords, :price, :stock, presence: true

    validate :baby_category_present?

    private

    def baby_category_present?
    end

end
