class SellerStripeSubscription < ApplicationRecord
  belongs_to :seller
  before_destroy :cancel_any_active_or_scheduled_subscription, prepend: true

  private
  def cancel_any_active_or_scheduled_subscription
    CancelSubscriptionsOnDestroySellerWorker.perform_async(self.subscription_schedule_id,self.subscription_stripe_id,self.status)
  end
end