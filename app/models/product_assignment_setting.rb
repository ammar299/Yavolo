class ProductAssignmentSetting < ApplicationRecord
  validates_presence_of :price, :duration, :items

  def self.create_default
    create(price: 200, items: 200, duration: 30)
  end
end
