class CancelSubscriptionEmailWorker
  include Sidekiq::Worker

  def perform(*args)
    seller_email = args[0]
    SellerStripeMailer.with( to: seller_email).cancel_stripe_subscription_email_to_seller.deliver_now
  end

end