class DeliveryOption < ApplicationRecord
  include PgSearch
  pg_search_scope :global_search, against: [:name]

  has_many :delivery_option_ships, dependent: :destroy
  has_many :ships, through: :delivery_option_ships
  has_many :products
  belongs_to :delivery_optionable, polymorphic: true

  scope :admin_delivery_option, lambda { |class_name| where("delivery_optionable_type = ?", class_name) }

end
