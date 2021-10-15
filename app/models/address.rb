class Address < ApplicationRecord
    belongs_to :seller
    validates :phone_number, phone: true
    enum address_type: { 
        business_representative_address: 0,
        business_address: 1,
        return_address: 2,
        invoice_address: 3,
     }
end
