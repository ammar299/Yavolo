class Admin < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  has_many :products, as: :owner, dependent: :destroy
  has_many :csv_imports, as: :importer, dependent: :destroy
  has_many :delivery_options, as: :delivery_optionable, dependent: :destroy

  def full_name
    "#{first_name} #{last_name}"
  end
end
