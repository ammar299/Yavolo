class BuyerPaymentMethod < ApplicationRecord
  belongs_to :buyer, optional: true
  has_many :orders, dependent: :destroy

  enum payment_method_type: {
    stripe: 0,
    paypal: 1,
    google_pay: 2,
    apple: 3
  }
end
