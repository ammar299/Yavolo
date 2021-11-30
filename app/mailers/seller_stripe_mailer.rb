class SellerStripeMailer < ApplicationMailer

  def cancel_stripe_subscription_email_to_seller
    seller_email = params[:to]
    mail(to: seller_email, subject: 'Cancel Subscription Request')
  end

  def send_cancel_subscription_notification_to_admin(seller_email)
    @seller_email = seller_email
    admins = Admin.all
    admins.each do |admin|
      puts "**************** email sent to admin too *****************"
      mail(to: admin.email, subject: 'Cancel Subscription Request')
    end
  end

  def cancel_scheduled_subscription
    seller_email = params[:to]
    mail(to: seller_email, subject: 'Subscription Canceled')
  end

  def cancel_active_subscription
    seller_email = params[:to]
    mail(to: seller_email, subject: 'Subscription Canceled')
  end

  def renew_subscription
    seller_email = params[:to]
    mail(to: seller_email, subject: 'Subscription Renewed')
  end

end
