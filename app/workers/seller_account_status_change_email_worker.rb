class SellerAccountStatusChangeEmailWorker
  include Sidekiq::Worker

  def perform(seller_id)
    seller = Seller.find(seller_id)
    puts "Sending email to seller #{seller.email}"
    if seller.activate? || seller.approve?
      SellerMailer.with(to: seller.email.downcase).send_account_activation_email.deliver_now
    elsif seller.rejected?
      SellerMailer.with(to: seller.email.downcase).send_account_rejected_email.deliver_now
    elsif seller.suspend?
      SellerMailer.with(to: seller.email.downcase).send_account_suspend_email.deliver_now
    end
  rescue StandardError => e
    puts e.message
    puts "Something went wrong while sending email"
  end

end
