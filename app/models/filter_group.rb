class FilterGroup < ApplicationRecord

  include PgSearch::Model
  multisearchable against: :filter_group_type
  pg_search_scope :search_by_name, against: :name

  has_many :filter_categories, dependent: :destroy
  has_many :filter_in_categories, dependent: :destroy
  has_many :categories, through: :filter_categories

  enum filter_group_type: { global: 0, local: 1 }

  accepts_nested_attributes_for :filter_in_categories, allow_destroy: true
  accepts_nested_attributes_for :filter_categories, allow_destroy: true
end
