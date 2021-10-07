class Product < ApplicationRecord
    enum condition: { brand_new: 0, refurbished: 1 }
    enum status: { draft: 0, active: 1, inactive: 2, pending: 3, disapproved: 4 }
    enum discount_unit:{ percentage: 0, amount: 1 }

    has_one :seo_content, dependent: :destroy
    has_one :ebay_detail, dependent: :destroy
    has_one :google_shopping, dependent: :destroy

    has_many :pictures, as: :imageable, dependent: :destroy

    belongs_to :owner, polymorphic: true
end