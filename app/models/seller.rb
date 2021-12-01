class Seller < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  # validate :date_of_birth_is_valid_datetime
  validate :status_change_is_valid
  devise :database_authenticatable, :registerable, :lockable,
         :recoverable, :rememberable, :validatable, :trackable, :omniauthable, omniauth_providers: [:google_oauth2 , :facebook]
  validates :email, confirmation: true, presence: true
  # validates :contact_number, phone: {allow_blank: true}
  validates_acceptance_of :terms_and_conditions, on: :on_final_step?
  validates_acceptance_of :recieve_deals_via_email, on: :on_final_step?
  has_one :business_representative, dependent: :destroy
  has_many :addresses, as: :addressable, dependent: :destroy
  has_one :company_detail, dependent: :destroy
  has_one :picture, as: :imageable, dependent: :destroy
  has_many :seller_apis,dependent: :destroy
  has_one :return_and_term,dependent: :destroy
  has_many :delivery_options, as: :delivery_optionable, dependent: :destroy
  has_one :bank_detail, dependent: :destroy
  has_many :csv_imports, as: :importer, dependent: :destroy
  has_one :paypal_detail,dependent: :destroy
  has_one :stripe_customer,as: :stripe_customerable,dependent: :destroy
  has_one :seller_stripe_subscription,dependent: :destroy
  has_many :seller_payment_methods,dependent: :destroy
  has_many :billing_listing_stripe,dependent: :destroy
  # has_one :stripe_bank_detail,dependent: :destroy

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
    month_12: 0,
    month_24: 1,
    month_36: 2,
    lifetime: 3,
  }
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP } 
  accepts_nested_attributes_for :business_representative
  accepts_nested_attributes_for :addresses
  accepts_nested_attributes_for :company_detail
  accepts_nested_attributes_for :picture
  accepts_nested_attributes_for :bank_detail
  attr_accessor :skip_password_validation  # virtual attribute to skip password validation while saving


  has_many :products, as: :owner, dependent: :destroy

  scope :available_sellers_for_product, -> { where(account_status: ['approve', 'activate']) }

  def self.create_from_provider_data(provider_data)
    where(email: provider_data.info.email, uid: provider_data.uid).first_or_create do |user|
      user.email = provider_data.info.email
      user.first_name = provider_data.info.name.split.first
      user.surname = provider_data.info.name.split.second
      user.provider = provider_data.provider
      user.password = Devise.friendly_token[0,20]
    end
  end

  def to_csv(all_sellers)
    attributes = %w{user_email user_first_name user_surname account_status listing_status subscription_type company_name
      company_legal_business_name company_doing_business_as company_companies_house_registration_number company_vat_number company_business_industry company_country company_website_url
      company_amazon_url company_ebay_url  
      business_representative_full_legal_name business_representative_email business_representative_job_title business_representative_date_of_birth

      business_representative_address_line_1 business_representative_address_line_2 business_representative_address_city business_representative_address_county business_representative_address_country business_representative_address_postal_code business_representative_address_phone_number 
      business_address_line_1 business_address_line_2 business_address_city business_address_county business_address_country business_address_postal_code business_address_phone_number 
      return_address_line_1 return_address_line_2 return_address_city return_address_county return_address_country return_address_postal_code return_address_phone_number
      invoice_address_line_1 invoice_address_line_2 invoice_address_city invoice_address_county invoice_address_country invoice_address_postal_code invoice_address_phone_number
    }
    
    CSV.generate(headers: true) do |csv|
      csv << attributes
      all_sellers.each do |seller|        
        csv << [seller.email, seller.first_name, seller.last_name, seller.account_status, seller.listing_status, seller.subscription_type,
          seller&.company_detail&.name, seller&.company_detail&.legal_business_name, seller&.company_detail&.doing_business_as, seller&.company_detail&.companies_house_registration_number, seller&.company_detail&.vat_number, seller&.company_detail&.business_industry, seller&.company_detail&.country, seller&.company_detail&.website_url,  seller&.company_detail&.amazon_url,seller&.company_detail&.ebay_url,
          seller&.business_representative&.full_legal_name, seller&.business_representative&.email, seller&.business_representative&.job_title , seller&.business_representative&.date_of_birth,
          
          seller&.addresses[0]&.address_line_1, seller&.addresses[0]&.address_line_2, seller&.addresses[0]&.city , seller&.addresses[0]&.county ,seller&.addresses[0]&.country , seller&.addresses[0]&.postal_code , seller&.addresses[0]&.phone_number ,
          seller&.addresses[1]&.address_line_1, seller&.addresses[1]&.address_line_2, seller&.addresses[1]&.city , seller&.addresses[1]&.county , seller&.addresses[1]&.country , seller&.addresses[1]&.postal_code , seller&.addresses[1]&.phone_number ,
          seller&.addresses[2]&.address_line_1, seller&.addresses[2]&.address_line_2, seller&.addresses[2]&.city , seller&.addresses[2]&.county , seller&.addresses[2]&.country , seller&.addresses[2]&.postal_code , seller&.addresses[2]&.phone_number ,
          seller&.addresses[3]&.address_line_1, seller&.addresses[3]&.address_line_2, seller&.addresses[3]&.city , seller&.addresses[3]&.county , seller&.addresses[3]&.country , seller&.addresses[3]&.postal_code , seller&.addresses[3]&.phone_number ,
        ]
      end
    end
  end

  def get_current_plan(plan_id)
    current_plan_detail = Stripe::Price.retrieve(
      plan_id,
    )
    product_detail = get_current_product(current_plan_detail)
    return product_detail
  end

  def get_current_product(current_plan_detail)
    product =Stripe::Product.retrieve(current_plan_detail.product)
    return product
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def wizard_steps_completed?
    [self.company_detail.present?, self.addresses.where(address_type: 'business_address').first.present?,
     self.business_representative.present?, self.addresses.where(address_type: 'business_representative_address').first.present?,
     self.bank_detail.present?].all?(true)
  end

  def send_account_status_changed_email_to_seller
    return unless has_account_status_changed?
    SellerAccountStatusChangeEmailWorker.perform_async(self.id)
  end

  def has_account_status_changed?
    self.previous_changes.has_key?("account_status")
  end

  def get_seller_stripe_account
    begin
      Stripe::Account.retrieve(self.bank_detail.customer_stripe_account_id) if self.bank_detail.customer_stripe_account_id.present?
    rescue StandardError => e
      nil
    end
  end

  def update_seller_products_listing
    if has_account_status_changed?
      if self.suspend? || self.pending?
        self.in_active!
        de_active_all_products
      elsif self.activate? || self.approve?
        self.active!
        active_all_products
      end
    elsif self.in_active? #if listing status has changed
      de_active_all_products
    elsif self.active? #if listing status has changed
      active_all_products
    end
  end

  protected

  def password_required?
    return false if skip_password_validation
    super
  end

  private

  def active_all_products
    self.products.where(status: :inactive).update_all(status: :active)
  end

  def de_active_all_products
    self.products.where(status: :active).update_all(status: :inactive)
  end

  def date_of_birth_is_valid_datetime
    return unless date_of_birth.present?
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

  def status_change_is_valid
    return unless account_status_changed?

    if %w(approve activate).include?(account_status_was) && (self.rejected? || self.pending?)
      errors.add(:account_status, "cannot be changed to #{self.account_status}")
    elsif account_status_was != "pending" && self.rejected?
      errors.add(:account_status, "cannot be changed to rejected")
    end

  end

end
