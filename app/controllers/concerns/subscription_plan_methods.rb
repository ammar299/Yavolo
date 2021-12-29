module SubscriptionPlanMethods
  extend ActiveSupport::Concern

  def set_default_plan(params)
    if SubscriptionPlan.all.count == 0
      return true
    else
      set_default_subscription(params)
    end
  end

  def set_default_subscription(params)
    value = false
    if params[:default_subscription] == true || params[:default_subscription] == "on"
      set_other_default_as_false(params)
      value = true
    end
    return value
  end

  def set_other_default_as_false(params)
    SubscriptionPlan.where(default_subscription: true)&.each do |plan|
      if params[:id].to_i != plan[:id].to_i
        plan.default_subscription = false
        plan.save
      end
    end
  end

  def updator_service_call_valid?(params,subscription)
    value = true
    value = false if subscription&.subscription_name == params[:subscription_name] && subscription&.price&.to_f == params[:subscription_price].to_f
    value
  end

  def rephrase_default_status(params)
    value = false
   if params[:default_subscription].present? && params[:default_subscription] == "on"
    value = true
   end
   params[:default_subscription] = value
  end

  def get_plan_name(params)
    SubscriptionPlan.where(plan_name_id: params[:data][:object][:items][:data].last[:price][:product])&.last&.subscription_name
  end

  def check_invoice_status
    ['invoice.created','invoice.updated','invoice.deleted','invoice.finalization_failed',
      'invoice.finalized','invoice.marked_uncollectible','invoice.paid','invoice.payment_action_required',
        'invoice.payment_failed','invoice.payment_succeeded','invoice.sent','invoice.upcoming','invoice.voided']
  end

  def subscription_params(sub,seller)
    {
      subscription_stripe_id: sub.id,
      plan_id: sub.items&.data[0]&.price&.id,
      status: sub.status,
      current_period_end: date_parser(sub.current_period_end),
      current_period_start: date_parser(sub.current_period_start),
      customer: sub.customer,
      schedule_date: date_parser(sub.start_date),
      product_id: sub.items&.data[0]&.price&.product,
      plan_name: current_default_plan(seller).subscription_name,
      subscription_data: sub
    }
  end

  def current_default_plan(seller)
    if seller.provider != "admin"
      SubscriptionPlan.where(default_subscription: true)&.last
    else
      SubscriptionPlan.where(subscription_name: seller.subscription_type)&.last
    end
  end

  def update_stripe_subscription(subscription,new_plan_id)
    Stripe::Subscription.update(
      subscription.subscription_stripe_id,
      {
        cancel_at: time_to_cancel(get_associated_plan(new_plan_id)).to_i,
        items: [
          {
            price: new_plan_id
          },
        ]
      },
    )
  end

  def update_stripe_subscription_to_active(subscription,new_plan_id)
    Stripe::Subscription.update(
      subscription.subscription_stripe_id,
      {
        cancel_at_period_end: false,
        items: [
          {
            price: new_plan_id
          },
        ]
      },
    )
  end

  def get_associated_plan(plan)
    SubscriptionPlan.find_by(plan_id: plan)
  end

  def delete_prev_plan_from_subscription(subscription)
    Stripe::SubscriptionItem.delete(
      subscription.items.data.first.id,
    )
  end

  def stripe_params(new_plan_name,stripe_subscription)
    {
      plan_name: new_plan_name,
      status: stripe_subscription.status,
      plan_id: stripe_subscription.items&.data.last&.plan&.id,
      product_id: stripe_subscription.items&.data.last&.plan&.product,
      cancel_at_period_end: stripe_subscription.cancel_at_period_end,
      current_period_end: date_parser(stripe_subscription.current_period_end),
      current_period_start: date_parser(stripe_subscription.current_period_start),
      subscription_data: stripe_subscription
    }
  end

  def notify_through_email(email,msg)
    UpdateSubscriptionEmailWorker.perform_async(email,msg)
  end

  def rolling_status(rolling_status)
    status = true
    status = false  if rolling_status.nil?
    status
  end

  def time_to_cancel(default_plan)
    value = Time.now + default_plan.subscription_months.to_i.months
  end

end
