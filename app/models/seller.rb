class Seller < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :timeoutable, :trackable, :omniauthable, omniauth_providers: [:google_oauth2 , :facebook]
  validates :email, confirmation: true
  validates :contact_number, phone: {allow_blank: true}
  has_one :business_representative, dependent: :destroy
  has_many :addresses, dependent: :destroy
  has_one :company_detail, dependent: :destroy
  has_one :picture, as: :imageable, dependent: :destroy
  has_one :seller_api
  
  
  enum account_status: {
    pending: 0,
    approve: 1,
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
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP } 
  accepts_nested_attributes_for :business_representative
  accepts_nested_attributes_for :addresses
  accepts_nested_attributes_for :company_detail
  accepts_nested_attributes_for :picture
  attr_accessor :skip_password_validation  # virtual attribute to skip password validation while saving


  has_many :products, as: :owner, dependent: :destroy

  def self.create_from_provider_data(provider_data)
    where(email: provider_data.info.email, uid: provider_data.uid).first_or_create do |user|
      user.email = provider_data.info.email
      user.first_name = provider_data.info.name.split.first
      user.surname = provider_data.info.name.split.second
      user.provider = provider_data.provider
      user.password = Devise.friendly_token[0,20]
    end
  end

  def self.to_csv
    attributes = %w{id email first_name last_name surname gender date_of_birth contact_number provider uid account_status listing_status contact_email contact_name subscription_type}
    CSV.generate(headers: true) do |csv|
      csv << attributes
      all.each do |seller|
        csv << attributes.map{ |attr| seller.send(attr) }
      end
    end
  end


  protected
  def username
    [first_name, last_name].join(' ')
  end

  def password_required?
    return false if skip_password_validation
    super
  end
  # Usage
  # @seller.skip_password_validation = true
  # @seller.save
end
