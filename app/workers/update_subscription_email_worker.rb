class UpdateSubscriptionEmailWorker
  include Sidekiq::Worker

  def perform(*args)
    seller_email = args[0]
    case args[1]
    when "cancel_after_next_payment_taken"
      SellerStripeMailer.with( to: seller_email).cancel_after_next_payment_taken.deliver_now
    when "cancel_at_period_end"
      SellerStripeMailer.with( to: seller_email).cancel_at_period_end.deliver_now
    when "renew_subscription"
      SellerStripeMailer.with( to: seller_email).renew_subscription.deliver_now
    when "subscription_updated"
      SellerStripeMailer.with( to: seller_email).subscription_updated.deliver_now
    when "canceled"
      SellerStripeMailer.with( to: seller_email).subscription_canceled.deliver_now
    when "create_subscription"
      SellerStripeMailer.with( to: seller_email).subscription_created.deliver_now
    else
      puts "Email category not found."
    end
  end

end