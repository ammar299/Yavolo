class FilterCategory < ApplicationRecord
  belongs_to :filter_group, optional: true
end
