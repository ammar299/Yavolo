class BusinessRepresentative < ApplicationRecord
    belongs_to :seller
    validates :email, format: { with: URI::MailTo::EMAIL_REGEXP } 
end
