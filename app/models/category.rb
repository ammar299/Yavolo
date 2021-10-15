class Category < ApplicationRecord
  has_ancestry

  has_many :category_filter_groups, dependent: :destroy
  has_many :filter_groups, through: :category_filter_groups

  # validates :category_id, uniqueness: true,presence: true
end
