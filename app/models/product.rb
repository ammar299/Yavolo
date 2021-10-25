class Product < ApplicationRecord
    extend FriendlyId
    friendly_id :title
    serialize :filter_in_category_ids, Array

    enum condition: { brand_new: 0, refurbished: 1 }
    enum status: { draft: 0, active: 1, inactive: 2, pending: 3, disapproved: 4, pending: 5 }
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


    scope :all_products, ->(owner) { where(owner_condition(owner)) }
    scope :active_products, ->(owner) { where(owner_condition(owner).merge!(status: :active)) }
    scope :inactive_products, ->(owner) { where(owner_condition(owner).merge!(status: :inactive)) }
    scope :pending_products, ->(owner) { where(owner_condition(owner).merge!(status: :pending)) }
    scope :draft_products, ->(owner) { where(owner_condition(owner).merge!(status: :draft)) }
    scope :yavolo_enabled_products, ->(owner) { where(owner_condition(owner).merge!(yavolo_enabled: true)) }


    def self.get_group_by_status_count(owner)
        group_by_hash = Product.where(owner_id: owner.id, owner_type: owner.class.name).group(:status).count
        group_by_hash.merge!(all: Product.all_products(owner).count)
        group_by_hash.merge!(yavolo_enabled: Product.yavolo_enabled_products(owner).count)
        group_by_hash.delete(nil)
        group_by_hash.collect{|k,v| [k.to_sym, v]}.to_h
    end

    def self.owner_condition(owner)
        {owner_id: owner.id, owner_type: owner.class.name}
    end
    
end
