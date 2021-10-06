class DeliveryOptionShip < ApplicationRecord
  belongs_to :delivery_option
  belongs_to :ship
end
