class Buyer < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :timeoutable, :trackable, :omniauthable,
         omniauth_providers: [:google_oauth2 , :facebook]
  attr_accessor :skip_password_validation  # virtual attribute to skip password validation while saving
  validates :email, confirmation: true, presence: true
  validates_acceptance_of :terms_and_conditions
  validates_acceptance_of :receive_deals_via_email

  has_many :orders, dependent: :destroy
  has_one :stripe_customer, as: :stripe_customerable, dependent: :destroy
  has_many :buyer_payment_methods, dependent: :destroy
  has_many :refund_modes, dependent: :destroy

  def self.create_from_provider_data(provider_data)
    where(email: provider_data.info.email, uid: provider_data.uid).first_or_create do |user|
      user.email = provider_data.info.email
      user.first_name = provider_data.info.name.split.first
      user.surname = provider_data.info.name.split.second
      user.provider = provider_data.provider
      user.password = Devise.friendly_token[0,20]
      user.terms_and_conditions = true
      user.receive_deals_via_email = true
    end
  end

  protected
  def password_required?
    return false if skip_password_validation
    super
  end
end
