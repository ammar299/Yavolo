class CancelSubscriptionAfterPaymentTakenWorker
  include SubscriptionPlanMethods
  include Admin::SubscriptionsHelper
  include Sidekiq::Worker
  def perform(*args)
    @seller_id = args[0]
    begin
      if cancel_after_next_payment_taken?
        cancel_subscription
      end
    rescue => e
      puts "cancel_after_next_payment_taken worker exception: #{e.message}"
    end
  end

  private

  def cancel_after_next_payment_taken?
    subscription = seller_subscription.reload
    value = false
    if subscription.cancel_after_next_payment_taken?
      value = true
    end
    return value
  end

  def cancel_subscription
    sub = Stripe::Subscription.delete(
      seller_subscription.subscription_stripe_id,
    )
    record =  update_current_subscription(sub) if sub.status == 'canceled'
  end

  def seller_subscription
    @seller_stripe_subscription ||= seller.seller_stripe_subscription
  end

  def seller
    @seller ||= Seller.where(id: @seller_id.to_i)&.last
  end

  def update_current_subscription(sub)
    seller_subscription.update(update_params(sub))
    notify_through_email(seller.email,"canceled")
  end

  def update_params(sub)
    {
      status: sub.status,
      cancel_at_period_end: sub.cancel_at_period_end,
      canceled_at: date_parser(sub.canceled_at),
      seller_requested_cancelation: false,
      cancel_after_next_payment_taken: false,
      cancel_at: date_parser(sub.cancel_at),
      current_period_end: date_parser(sub.current_period_end),
      current_period_start: date_parser(sub.current_period_start),
      subscription_data: sub
    }
  end

end