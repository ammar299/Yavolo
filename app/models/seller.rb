class Seller < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  validate :date_of_birth_is_valid_datetime
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :trackable, :omniauthable, omniauth_providers: [:google_oauth2 , :facebook]
  validates :email, confirmation: true, presence: true
  validates :date_of_birth, presence: true
  # validates :contact_number, phone: {allow_blank: true}
  validates_acceptance_of :terms_and_conditions, on: :on_final_step?
  validates_acceptance_of :recieve_deals_via_email, on: :on_final_step?
  has_one :business_representative, dependent: :destroy
  has_many :addresses, as: :addressable, dependent: :destroy
  has_one :company_detail, dependent: :destroy
  has_one :picture, as: :imageable, dependent: :destroy
  has_many :seller_apis
  has_one :return_and_term
  has_many :delivery_options, as: :delivery_optionable, dependent: :destroy
  has_one :bank_detail, dependent: :destroy
  has_many :csv_imports, as: :importer, dependent: :destroy
  has_one :paypal_detail,dependent: :destroy

  enum timeout: {
    "After 1 hour of no activity": 1,
    "After 2 hour of no activity": 2,
    "After 3 hour of no activity": 3,
    "After 4 hour of no activity": 4,
    "After 5 hour of no activity": 5,
    "After 6 hour of no activity": 6,
    "After 7 hour of no activity": 7,
    "After 8 hour of no activity": 8,
    "After 9 hour of no activity": 9,
    "After 10 hour of no activity": 10,
    "After 11 hour of no activity": 11,
    "After 12 hour of no activity": 12,
    "After 24 hour of no activity": 24,
  }
  enum account_status: {
    pending: 0,
    approve: 1,
    rejected: 2,
    activate: 3,
    suspend: 4,
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
  accepts_nested_attributes_for :bank_detail
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
    #seller_api_name seller_api_token seller_api_status seller_api_seller_id
    #seller&.seller_api&.name , seller&.seller_api&.api_token , seller&.seller_api&.status , seller&.seller_api&.seller_id,
    # picture_name picture_imageable_id picture_imageable_type after
    # seller&.picture&.name,seller&.picture&.imageable_id,seller&.picture&.imageable_type,
    attributes = %w{id email first_name last_name surname gender date_of_birth contact_number provider uid account_status listing_status contact_email contact_name subscription_type company_detail_name
      company_detail_vat_number company_detail_country company_detail_legal_business_name company_detail_companies_house_registration_number company_detail_business_industry company_detail_business_phone company_detail_website_url
      company_detail_amazon_url company_detail_ebay_url company_detail_doing_business_as  
      business_representative_email business_representative_job_title business_representative_date_of_birth business_representative_contact_number business_representative_full_legal_name

      business_representative_address_line_1 business_representative_address_line_2 business_representative_address_city business_representative_address_county business_representative_address_state business_representative_address_country business_representative_address_postal_code business_representative_address_phone_number business_representative_address_type 
      business_address_line_1 business_address_line_2 business_address_city business_address_county business_address_state business_address_country business_address_postal_code business_address_phone_number business_address_type 
      return_address_line_1 return_address_line_2 return_address_city return_address_county return_address_state return_address_country return_address_postal_code return_address_phone_number return_address_type
      invoice_address_line_1 invoice_address_line_2 invoice_address_city invoice_address_county invoice_address_state invoice_address_country invoice_address_postal_code invoice_address_phone_number invoice_address_type
    }
    CSV.generate(headers: true) do |csv|
      csv << attributes
      all.each do |seller|        
        csv << [seller.id, seller.email, seller.first_name, seller.last_name, seller.surname, seller.gender, seller.date_of_birth, seller.contact_number, seller.provider, seller.uid, seller.account_status, seller.listing_status, seller.contact_email, seller.contact_name, seller.subscription_type,
          seller&.company_detail&.name,  seller&.company_detail&.vat_number,seller&.company_detail&.country,  seller&.company_detail&.legal_business_name,  seller&.company_detail&.companies_house_registration_number,  seller&.company_detail&.business_industry,  seller&.company_detail&.business_phone, seller&.company_detail&.website_url,  seller&.company_detail&.amazon_url,seller&.company_detail&.ebay_url,  seller&.company_detail&.doing_business_as,
          seller&.business_representative&.email, seller&.business_representative&.job_title , seller&.business_representative&.date_of_birth, seller&.business_representative&.contact_number, seller&.business_representative&.full_legal_name,
          
          seller&.addresses[0]&.address_line_1, seller&.addresses[0]&.address_line_2, seller&.addresses[0]&.city , seller&.addresses[0]&.county , seller&.addresses[0]&.state , seller&.addresses[0]&.country , seller&.addresses[0]&.postal_code , seller&.addresses[0]&.phone_number , seller&.addresses[0]&.address_type,
          seller&.addresses[1]&.address_line_1, seller&.addresses[1]&.address_line_2, seller&.addresses[1]&.city , seller&.addresses[1]&.county , seller&.addresses[1]&.state , seller&.addresses[1]&.country , seller&.addresses[1]&.postal_code , seller&.addresses[1]&.phone_number , seller&.addresses[1]&.address_type,
          seller&.addresses[2]&.address_line_1, seller&.addresses[2]&.address_line_2, seller&.addresses[2]&.city , seller&.addresses[2]&.county , seller&.addresses[2]&.state , seller&.addresses[2]&.country , seller&.addresses[2]&.postal_code , seller&.addresses[2]&.phone_number , seller&.addresses[2]&.address_type,
          seller&.addresses[3]&.address_line_1, seller&.addresses[3]&.address_line_2, seller&.addresses[3]&.city , seller&.addresses[3]&.county , seller&.addresses[3]&.state , seller&.addresses[3]&.country , seller&.addresses[3]&.postal_code , seller&.addresses[3]&.phone_number , seller&.addresses[3]&.address_type,
        ]
      end
    end
  end

  def date_of_birth_is_valid_datetime
    begin
      date_of_birth.to_date
    rescue
      errors.add(:date_of_birth, "must be a date")
    else
      if date_of_birth > Time.now
        errors.add(:date_of_birth, "date of birth cannot be in the future")
      elsif date_of_birth < Time.now - 125.years
        errors.add(:date_of_birth, "date of birth cannot be over 125 years ago")
      end
    end
  end


  protected

  def password_required?
    return false if skip_password_validation
    super
  end
  # Usage
  # @seller.skip_password_validation = true
  # @seller.save
end
