class Category < ApplicationRecord
  has_ancestry
  validates :category_name, uniqueness: true,presence: true
end
