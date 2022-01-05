class RefundDetail < ApplicationRecord

  belongs_to :order
  belongs_to :refund
  belongs_to :product
  belongs_to :line_item

  validate :check_amount_refund_per_line_item

  def check_amount_refund_per_line_item
    if amount_refund.present? && amount_paid.present?
      if amount_refund > amount_paid
        errors.add(:amount_refund, "must less than the amount paid")
      end
    end
  end
end
