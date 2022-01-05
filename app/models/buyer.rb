class Buyer < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :timeoutable, :trackable
  attr_accessor :skip_password_validation  # virtual attribute to skip password validation while saving

  has_many :orders, dependent: :destroy
  has_one :stripe_customer, as: :stripe_customerable, dependent: :destroy
  has_many :buyer_payment_methods, dependent: :destroy
  has_many :refund_modes, dependent: :destroy



  protected
  def password_required?
    return false if skip_password_validation
    super
  end
end
