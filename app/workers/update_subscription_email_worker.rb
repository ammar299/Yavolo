class UpdateSubscriptionEmailWorker
  include Sidekiq::Worker

  def perform(*args)
    seller_email = args[0]
    case args[1]
    when "canceled_immediateley"
      SellerStripeMailer.with( to: seller_email).cancel_scheduled_subscription.deliver_now
    when "canceled_at_time_end"
      SellerStripeMailer.with( to: seller_email).cancel_active_subscription.deliver_now
    when "renew_subscription"
      SellerStripeMailer.with( to: seller_email).renew_subscription.deliver_now
    else
      puts "Email category not found."
    end
  end

end