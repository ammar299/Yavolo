class FilterGroup < ApplicationRecord
  has_many :filter_categories, dependent: :destroy
  has_many :filter_in_categories, dependent: :destroy

  enum filter_group_type: { local: 0, global: 1 }

  accepts_nested_attributes_for :filter_in_categories ,allow_destroy: true
  accepts_nested_attributes_for :filter_categories, allow_destroy: true

end
