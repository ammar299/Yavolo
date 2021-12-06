class Product < ApplicationRecord
    include RansackObject
    extend FriendlyId
    friendly_id :title
    serialize :filter_in_category_ids, Array

    attr_accessor :check_for_seo_content_uniqueness

    enum condition: { brand_new: 0, refurbished: 1 }
    enum status: { draft: 0, active: 1, inactive: 2, pending: 3, disapproved: 4 }
    enum discount_unit:{ percentage: 0, amount: 1 }

    has_one :seo_content, dependent: :destroy
    has_one :ebay_detail, dependent: :destroy
    has_one :google_shopping, dependent: :destroy
    has_one :assigned_category, dependent: :destroy
    has_one :category, through: :assigned_category, dependent: :destroy

    # Product has many
    has_many :line_items, dependent: :destroy


    has_many :pictures, as: :imageable, dependent: :destroy
    alias_attribute  :images, :pictures

    belongs_to :owner, polymorphic: true, optional: true
    belongs_to :delivery_option

    accepts_nested_attributes_for :seo_content, :ebay_detail, :google_shopping, :assigned_category
    accepts_nested_attributes_for :pictures, allow_destroy: true

    validates :ean, presence: true
    # validates :sku, uniqueness: true, if: Proc.new{|p| p.sku.present? }
    validates :ean, uniqueness: true, if: Proc.new{|p| p.ean.present? }
    validates :yan, uniqueness: true, if: Proc.new{|p| p.yan.present? }
    validates :title, :condition, :description, :keywords, presence: true
    validates :discount, presence: true, inclusion: { in: 2.5..100, message: "value should be between 2.5 and 100" }
    validates :stock,:price, presence: true, inclusion: { in: 0..MAX_STOCK_VALUE, message: "value should be between 0 and #{MAX_STOCK_VALUE}" }
    validate :validate_seller
    validates_format_of :ean, with: /\A(\d{12})?\z/

    def validate_seller
        if owner_id.blank?
            errors.add(:owner_id, "Seller can't be blank")
        else
            seller = Seller.where(id: owner_id).first
            if seller.blank? 
                errors.add(:owner_id, "Seller not found")
            else
                owner_type == 'Seller'
            end
        end
    end


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

    def self.yavolo_percent(seller)
        total_count = Product.where(owner_id: seller.id, owner_type: seller.class.name).count
        yavolo_count = Product.where(owner_id: seller.id, owner_type: seller.class.name, yavolo_enabled: true).count
        return 0 if total_count.zero?
        ((yavolo_count.to_d/total_count.to_d)*100.0).to_i
    end
end
