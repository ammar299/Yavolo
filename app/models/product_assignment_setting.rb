class ProductAssignmentSetting < ApplicationRecord
  validates_presence_of :price, :duration, :items
end
