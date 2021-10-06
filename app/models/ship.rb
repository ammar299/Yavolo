class Ship < ApplicationRecord
  has_many :delivery_option_ships, dependent: :destroy
  has_many :delivery_options, through: :delivery_option_ships

  validates :name, uniqueness: true
end
