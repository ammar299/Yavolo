class ReversalMode < ApplicationRecord

  belongs_to :order
  belongs_to :refund
  belongs_to :seller
  belongs_to :line_item

  enum reversal_through: {
    stripe: 0,
    paypal: 1,
    google_pay: 2,
    apple_pay: 3
  }

end
