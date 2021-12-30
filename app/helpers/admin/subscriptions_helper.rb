module Admin::SubscriptionsHelper

  def rolling(sub)
    value = "false"
    if sub.rolling_subscription.present? && sub.rolling_subscription == "on"
      value = "true"
    end
    value
  end

  def plan_has_subscription?(plan)
    status = false
    SellerStripeSubscription.where(plan_id: plan)&.each do |subscription|
      status = true 
      break
    end
    return status
  end

  def subscription_plans
    SubscriptionPlan.all
  end

  def plan_name
    seller_subscription&.plan_name || "Default"
  end

  def subscription_is?(type)
    @seller.provider == "admin" && @seller.subscription_type == type && seller_subscription.status != "active"
  end

  def expiry_date
    seller_subscription&.current_period_end&.strftime('%d/%m/%y %T')
  end

  def seller_commission
    number_with_precision(seller_selected_plan&.commission_excluding_vat, precision: 2) if seller_selected_plan&.commission_excluding_vat.present?
  end

  def renewal_cost
    number_with_precision(seller_selected_plan&.price, precision: 2)
  end

  def seller_selected_plan
    @subscription_plan ||= SubscriptionPlan.where(plan_id: seller_subscription&.plan_id)&.last
  end

  def cancel_at_period_end_nil_or_false?
    [
      seller_subscription&.cancel_at_period_end.nil?, 
      seller_subscription&.cancel_at_period_end == false,
    ].any?(true)
  end

  def cancel_after_next_payment_taken?
    seller_subscription&.cancel_after_next_payment_taken
  end

  def subsciption_status
    seller_subscription.status
  end

  def selected_or_not(option)
    value = ""
    name = seller_subscription&.plan_name&.strip
    if name == option&.subscription_name&.strip
      value = "selected"
    end
    value
  end

  def canceled_or_not
    value = ""
    if seller_subscription.status == "canceled"
      value = "selected"
    end
    value
  end

  def enforce_sub_dropdown(option)
    if option == "next-payment-taken"
      select_dropdown_value(true)
    elsif option == "current-subscriptions-end"
      select_dropdown_value(false)
    else
      ""
    end
      
  end

  def select_dropdown_value(value)
    if seller_subscription&.cancel_after_next_payment_taken == value
      "selected"
    else
      ""
    end
  end

  def subscription_renew_path
    admin_seller_renew_seller_subscription_path(@seller)
  end

  def subscription_status_active_or_not_started?
    true if seller_subscription.present? && ( seller_subscription&.status == 'active' || seller_subscription&.status == 'not_started' ) 
  end

  def subscription_canceled?
    true if seller_subscription.present? && seller_subscription&.status == 'canceled'
  end

  def canceled_at
    seller_subscription&.canceled_at&.strftime('%d/%m/%y %T') 
  end

  def seller_requested_cancelation?
    @seller.seller_stripe_subscription.seller_requested_cancelation
  end

  def is_eligible_for_save?
    (seller_subscription.present? && cancel_at_period_end_nil_or_false? && !cancel_after_next_payment_taken? && !subscription_canceled?)
  end
  
  def seller_subscription
    @seller_subscription ||= @seller&.seller_stripe_subscription&.reload
  end

  def date_parser(date)
    begin 
      Time.at(date)
    rescue
      nil
    end
  end

end
