class CancelSubscriptionEmailWorker
  include Sidekiq::Worker

  def perform(*args)
    seller_email = args[0]
    reason = args[1] || "not mentioned"
    SellerStripeMailer.with( to: seller_email).cancel_stripe_subscription_email_to_seller.deliver_now
    SellerStripeMailer.send_cancel_subscription_notification_to_admin(seller_email,reason).deliver_now
  end

end