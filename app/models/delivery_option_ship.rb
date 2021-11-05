class DeliveryOptionShip < ApplicationRecord
  enum processing_time: { 'same_day': 0, '1_-_2_days': 1, '3_-_4_days': 2, '5_-_6_days': 3, '7_days': 4 }
  enum delivery_time: { 'next_day': 0, '2_-_3_days': 1, '4_-_5_days': 2, '6_-_7_days': 3 }

  belongs_to :delivery_option
  belongs_to :ship

  validates :processing_time, :delivery_time, presence: true
end
