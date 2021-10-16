class FilterCategory < ApplicationRecord
  belongs_to :filter_group, optional: true
  belongs_to :category, optional: true
end
