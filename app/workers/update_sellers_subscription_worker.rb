class UpdateSellersSubscriptionWorker
  include Sidekiq::Worker
  include Admin::SubscriptionsHelper
  include SubscriptionPlanMethods

  def perform(new_params,new_plan_id,prev_plan_id,prev_plan_name_id,rolling_status,subscription_months)
    current_params = ActiveSupport::JSON.decode(new_params)
    SellerStripeSubscription.all.each do |subscription|
      begin
        if prev_plan_id == subscription.plan_id && subscription.status != "canceled"
          if current_params["rolling_subscription"].nil?
            stripe_subscription = update_stripe_subscription(subscription,new_plan_id)
          else
            stripe_subscription = update_stripe_subscription_to_active(subscription,new_plan_id)
          end
          if stripe_subscription.present?
            prev_price = delete_prev_plan_from_subscription(stripe_subscription)
            subscription.update(stripe_params(current_params["subscription_name"],stripe_subscription)) if prev_price.deleted?
          end
          notify_through_email(subscription.seller.email,"subscription_updated")
          delete_plan(prev_plan_id,prev_plan_name_id) if !plan_has_subscription?(prev_plan_id)
        end
      rescue => e
        puts "Error Message: #{e.message}"
      end
      sleep 1
    end
  end

  def delete_plan(plan,prev_plan_name_id)
    plan_delete = Stripe::Plan.delete(plan)
    delete_product(prev_plan_name_id) if plan_delete.deleted?
  end

  def delete_product(prev_plan_name_id)
    Stripe::Product.delete(prev_plan_name_id)
  end

end
