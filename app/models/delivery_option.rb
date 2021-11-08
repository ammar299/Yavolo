class DeliveryOption < ApplicationRecord
  include PgSearch
  # TODO: Please remove processing/delivery time from this modal becasue this fields are shift to another model thanks
  # multisearchable(
  #   against: [:name, :processing_time, :delivery_time],
  # )
  # pg_search_scope :global_search, against: [:name, :delivery_time, :processing_time]
  # pg_search_scope :delivery_search, against: :delivery_time

  has_many :delivery_option_ships, dependent: :destroy
  has_many :ships, through: :delivery_option_ships
  has_many :products
  belongs_to :delivery_optionable, polymorphic: true

  scope :admin_delivery_option, lambda { |class_name| where("delivery_optionable_type = ?", class_name) }

end
