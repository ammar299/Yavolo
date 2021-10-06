class FilterGroup < ApplicationRecord
  has_many :filter_categories
  has_many :filter_in_categories

  accepts_nested_attributes_for :filter_in_categories , :filter_categories
end
