class OrderMailer < ApplicationMailer

  def send_order_complete_mail
    buyer_email = params[:to]
    mail(to: buyer_email, subject: 'Order has been placed successfully!')
  end
end