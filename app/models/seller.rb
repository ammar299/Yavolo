class Seller < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :timeoutable, :trackable, :omniauthable, omniauth_providers: [:google_oauth2 , :facebook]
  validates :email, confirmation: true
  validates_format_of :contact_number,
  :with => /\A(?:\+?\d{1,3}\s*-?)?\(?(?:\d{3})?\)?[- ]?\d{3}[- ]?\d{4}\z/,
  :message => "- Phone numbers must be in xxx-xxx-xxxx format."
  has_one :business_representative
  has_one :address
  has_one :company_detail
  enum account_status: {
    pending: 0,
    approved: 1,
    rejected: 2,
  }
  enum listing_status: {
    active: 0,
    in_active: 1,
  }
  enum subscription_type: {
    monthly: 0,
    yearly: 1,
    lifetime: 2,
  }


         def self.create_from_provider_data(provider_data)
          where(email: provider_data.info.email, uid: provider_data.uid).first_or_create do |user|
            user.email = provider_data.info.email
            user.first_name = provider_data.info.name.split.first
            user.surname = provider_data.info.name.split.second
            user.provider = provider_data.provider
            user.password = Devise.friendly_token[0,20]
          end
        end
end
