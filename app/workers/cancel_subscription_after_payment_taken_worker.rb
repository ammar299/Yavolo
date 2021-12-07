class CancelSubscriptionAfterPaymentTakenWorker
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
    if subscription.cancel_after_next_payment_taken?
      true
    else
      false
    end
  end

  def release_schedule_subscription
    begin
      release = Stripe::SubscriptionSchedule.release(
        get_scheduled_subscription_id,
      )
    rescue => e
      puts "Error on releasing schedule subscription: #{e.message}"
    end
  end

  def cancel_subscription
    release_schedule_subscription if seller_subscription.cancel_at_period_end.nil? 
    sub = Stripe::Subscription.update(
      current_sub_id,
        {
          cancel_at_period_end: true,
        }
      )
    record =  update_current_subscription(sub) if sub.status == 'active'
  end

  def current_sub_id
    seller_subscription.subscription_stripe_id
  end

  def get_scheduled_subscription_id
    seller_subscription.subscription_schedule_id
  end

  def seller_subscription
    @seller_stripe_subscription ||= seller.seller_stripe_subscription
  end

  def seller
    @seller ||= Seller.where(id: @seller_id.to_i)&.last
  end

  def update_current_subscription(sub)
    seller_subscription.update(update_params(sub))
    UpdateSubscriptionEmailWorker.perform_async(seller.email,"canceled_at_time_end")
  end

  def update_params(sub)
    {
      subscription_stripe_id: sub.id,
      status: sub.status,
      cancel_at_period_end: sub.cancel_at_period_end || false,
      canceled_at: date_parser(sub.canceled_at),
      seller_requested_cancelation: false,
      subscription_data: sub
    }
  end

end