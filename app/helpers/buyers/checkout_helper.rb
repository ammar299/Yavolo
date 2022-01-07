module Buyers::CheckoutHelper

  def get_payment_method_svg_name(order)
    return unless order.buyer_payment_method.present?

    paid_through = order.payment_mode&.payment_through

    case paid_through
    when 'stripe'
      order.buyer_payment_method.brand == 'Visa' ? 'visa-card' : 'master-card'
    when 'paypal'
      'paypal'
    when 'google_pay'
      'g-pay'
    when 'apple_pay'
      'apple-pay'
    else
      'visa-card'
    end
  end

  def get_concatenated_address(address)
    "#{address.appartment} #{address.address_line_1} #{address.address_line_2}"
  end
end
