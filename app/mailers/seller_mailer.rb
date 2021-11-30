class SellerMailer < ApplicationMailer

  def send_account_creation_email
    mail(to: params[:to], subject: 'Yavolo: Your seller account has been created.')
    puts "---- Email Sent for seller account creation ------"
  end

  def send_account_activation_email
    mail(to: params[:to], subject: 'Yavolo: Your seller account has been activated.')
    puts "---- Email Sent for seller account activation ------"
  end

  def send_account_rejected_email
    mail(to: params[:to], subject: 'Yavolo: Your seller account has been rejected.')
    puts "---- Email Sent for seller account rejection ------"
  end

  def send_account_suspend_email
    mail(to: params[:to], subject: 'Yavolo: Your seller account has been suspended.')
    puts "---- Email Sent for seller account suspension ------"
  end


  def send_account_lock_email
    mail(to: params[:to], subject: 'Yavolo: Your seller account has been locked.')
    puts "---- Email Sent for seller account locked ------"
  end

  def send_account_unlock_email
    mail(to: params[:to], subject: 'Yavolo: Your seller account has been unlocked.')
    puts "---- Email Sent for seller account unlocked ------"

  def send_holiday_mode_email(seller)
    @seller_holiday_mode = seller.holiday_mode ? 'enabled' : 'disabled'
    mail(to: params[:to], subject: 'Yavolo: Holiday Mode')
    puts "---- Email Sent for Seller Holiday Mode status ------"
  end

end
