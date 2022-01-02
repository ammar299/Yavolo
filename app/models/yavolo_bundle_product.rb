class YavoloBundleProduct < ApplicationRecord
  belongs_to :product
  belongs_to :yavolo_bundle

  validates_presence_of :price

end
