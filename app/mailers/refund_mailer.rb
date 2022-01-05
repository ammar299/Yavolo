class RefundMailer < ApplicationMailer

  def send_buyer_email
    email = params[:to]
    @buyer_message = params[:buyer_message]
    @order_number = params[:order_number]
    mail(to: email, subject: "Refunding Message For #{@order_number}")
    puts "---- Refunding Email Sent To Buyer ------"
  end

  def send_seller_email
    email = params[:to]
    @seller_message = params[:seller_message]
    @order_number = params[:order_number]
    mail(to: email, subject: "Refunding Message For #{@order_number}")
    puts "---- Refunding Email Sent To Seller ------"
  end

end