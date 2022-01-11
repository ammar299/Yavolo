module RefundingValidationMethods
  extend ActiveSupport::Concern

  # we are checking if admin/seller entered amount higher than paid amount
  def refund_greater_than_paid?(amount_refund, total_paid)
    amount_refund.to_f > total_paid.to_f
  end

  # we are checking if total refund generated plus entered refund amount is exceeding by total paid
  def net_refund_greater_than_paid?(amount_refund, line_item_id)
    total_refund = ::LineItem.net_refund_of(line_item_id).to_f + amount_refund.to_f
    total_paid = ::LineItem.net_paid_of(line_item_id).to_f
    total_refund > total_paid
  end
end