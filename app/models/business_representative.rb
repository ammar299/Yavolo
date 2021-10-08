class BusinessRepresentative < ApplicationRecord
    belongs_to :seller
    validates :contact_number, phone: true
end
