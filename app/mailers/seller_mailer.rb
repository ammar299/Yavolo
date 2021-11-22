class SellerMailer < ApplicationMailer

  def send_account_creation_email
    mail(to: params[:to], subject: 'Yavolo: Your seller account has been created.')
    puts "---- Email Sent for seller account creation ------"
  end

  def send_account_activation_email
    mail(to: params[:to], subject: 'Yavolo: Your seller account has been activated.')
    puts "---- Email Sent for seller account activation ------"
  end

end
