class SellerStripeMailer < ApplicationMailer

  def cancel_stripe_subscription_email_to_seller
    seller_email = params[:to]
    mail(to: seller_email, subject: 'Cancel Subscription Request')
  end

  def send_cancel_subscription_notification_to_admin(seller_email,reason)
    @reason = reason
    @seller_email = seller_email
    admins = Admin.all
    admins.each do |admin|
      puts "**************** email sent to admin too *****************"
      mail(to: admin.email, subject: 'Cancel Subscription Request')
    end
  end

  def cancel_after_next_payment_taken
    seller_email = params[:to]
    mail(to: seller_email, subject: 'Subscription Canceled')
  end

  def cancel_at_period_end
    seller_email = params[:to]
    mail(to: seller_email, subject: 'Subscription Canceled')
  end

  def renew_subscription
    seller_email = params[:to]
    mail(to: seller_email, subject: 'Subscription Renewed')
  end

  def subscription_updated
    seller_email = params[:to]
    subscription_details = Seller.find_by(email: seller_email)&.seller_stripe_subscription
    @plan = SubscriptionPlan.find_by(plan_id: subscription_details.plan_id) if subscription_details.present?
    mail(to: seller_email, subject: 'Subscription Plan Updated')
  end

  def subscription_canceled
    seller_email = params[:to]
    mail(to: seller_email, subject: 'Subscription Canceled')
  end

  def subscription_created
    seller_email = params[:to]
    mail(to: seller_email, subject: 'Subscription Created')
  end

end
