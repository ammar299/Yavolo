class RefundMessage < ApplicationRecord

  belongs_to :order
  belongs_to :refund
  belongs_to :buyer, optional: true
  belongs_to :seller, optional: true
end
