class DeliveryOption < ApplicationRecord
  include PgSearch
  multisearchable(
    against: [:name, :processing_time, :delivery_time],
  )
  pg_search_scope :global_search, against: [:name, :delivery_time, :processing_time]
  pg_search_scope :delivery_search, against: :delivery_time

  enum processing_time: { 'same_day': 0, '1_-_2_days': 1, '3_-_4_days': 2, '5_-_6_days': 3, '7_days': 4 }
  enum delivery_time: { 'next_day': 0, '2_-_3_days': 1, '4_-_5_days': 2, '6_-_7_days': 3 }

  has_many :delivery_option_ships, dependent: :destroy
  has_many :ships, through: :delivery_option_ships
  belongs_to :delivery_optionable, polymorphic: true

  validates :processing_time, :delivery_time, presence: true

  scope :admin_delivery_option, lambda { |class_name| where("delivery_optionable_type = ?", class_name) }

end
