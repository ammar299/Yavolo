class BuyerPaymentMethod < ApplicationRecord
  belongs_to :buyer
  has_many :orders, dependent: :destroy
end
