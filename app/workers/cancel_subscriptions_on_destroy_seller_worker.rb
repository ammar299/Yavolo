class CancelSubscriptionsOnDestroySellerWorker
  include Sidekiq::Worker

  def perform(*args)
    schedule_sub_id = args[0]
    current_sub_id = args[1]
    status = args[2]
    begin
      if status == "active"
        cancel_active_subscription(schedule_sub_id,current_sub_id)
      elsif status == "not_started"
        cancel_scheduled_subscription(schedule_sub_id)
      end
    rescue => e
      puts e.message
    end
  end

  private
  def cancel_scheduled_subscription(schedule_sub_id)
    sub = Stripe::SubscriptionSchedule.cancel(
      schedule_sub_id,
    )
  end

  def cancel_active_subscription(schedule_sub_id,current_sub_id)
    release_schedule_subscription(schedule_sub_id)
    sub = Stripe::Subscription.update(
      current_sub_id,
        {
          cancel_at_period_end: true,
        }
      )
  end

  def release_schedule_subscription(schedule_sub_id)
    release = Stripe::SubscriptionSchedule.release(
      schedule_sub_id,
    )
  end

end