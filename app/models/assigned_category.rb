class AssignedCategory < ApplicationRecord
  include DuplicateRecord

  belongs_to :product
  belongs_to :category
  validate :validate_category

    def validate_category
        errors.add(:category_id, "Category can't be blank") if category_id.blank?
    end
end
