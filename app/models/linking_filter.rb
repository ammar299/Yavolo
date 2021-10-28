class LinkingFilter < ApplicationRecord
  belongs_to :filter_in_category
  belongs_to :category
end
