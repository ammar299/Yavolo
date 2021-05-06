class User < ApplicationRecord
  
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :trackable, :rememberable, :validatable, :omniauthable, omniauth_providers: [:google_oauth2 , :facebook]

  validates :terms_and_conditions, acceptance: true
  validates :email, confirmation: true
  validates :email_confirmation, presence: true

  # validates :best_deals_email
  has_one_attached :avatar
  
  def update_password_with_password(params, *options)
    current_password = params.delete(:current_password)
    result = if valid_password?(current_password)
                update(params, *options)
              else
                self.assign_attributes(params, *options)
                self.valid?
                self.errors.add(:current_password, current_password.blank? ? :blank : :invalid)
                false
              end
    # clean_up_passwords
    result
  end

  def self.create_from_provider_data(provider_data)
    where(provider: provider_data.data, uid: provider_data.uid).first_or_create do |user|
      user.email = provider_data.info.email
      user.first_name = provider_data.info.name.split.first
      user.last_name = provider_data.info.name.split.second
      user.provider = provider_data.provider
      user.password = Devise.friendly_token[0,20]
    end
  end

   def avatar_thumbnail
   	if avatar.attached?
   		avatar.variant(resize: "150x150!").processed
   	end
   end

end
