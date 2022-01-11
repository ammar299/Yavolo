class RefundDetail < ApplicationRecord

  belongs_to :order
  belongs_to :refund
  belongs_to :line_item

end
