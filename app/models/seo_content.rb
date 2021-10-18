class SeoContent < ApplicationRecord
  include DuplicateRecord

  belongs_to :product
  # validates :title, :url, :description, :keywords, presence: true
end
