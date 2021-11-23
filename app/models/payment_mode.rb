# Has the data of order payment mode
class PaymentMode < ApplicationRecord
  belongs_to :order

  enum payment_through: {
    stripe: 0,
    paypal: 1,
    google_paypal: 2,
    apple_pay: 3
  }
end
