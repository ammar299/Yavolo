class UpdateRollingForAllSellersSubscriptionWorker
  include Sidekiq::Worker
  include SubscriptionPlanMethods

  def perform(*args)
    plan = SubscriptionPlan.find_by(id: args[0].to_i)
    if plan.present?
      rolling_status = rolling_status(args[1])
      rolling_months = args[2]
      SellerStripeSubscription.all.each do |subscription|
        if plan.plan_id == subscription.plan_id && subscription.status != "canceled"
          Admins::Sellers::SubscriptionPlanRollingUpdaterService.call(subscription,rolling_months,rolling_status)
        end
      end
    end
  end

end