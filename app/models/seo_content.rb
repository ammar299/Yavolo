class SeoContent < ApplicationRecord
  belongs_to :product
  validates :title, :url, :description, :keywords, presence: true
end
