class CategoryExcludedFilterGroup < ApplicationRecord
	belongs_to :category
	belongs_to :filter_group
end
