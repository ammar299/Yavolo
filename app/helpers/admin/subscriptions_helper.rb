module Admin::SubscriptionsHelper

  def plan_name
    seller_subscription&.plan_name || "Default"
  end

  def free_till
    seller_subscription&.schedule_date&.strftime('%d/%m/%y %T')
  end

  def expiry_date
    seller_subscription&.current_period_end&.strftime('%d/%m/%y %T')
  end

  def renewal_cost
    val = "£0.00"
    if @seller.provider != "admin"
    val = "£29.00"
    end
  end

  def renewal_date
    seller_subscription&.updated_at&.strftime('%d/%m/%y %T')
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
    type = @seller&.subscription_type
    if type == option
      "selected"
    else
      ""
    end
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
    seller_subscription.canceled_at&.strftime('%d/%m/%y %T') 
  end

  def seller_subscription
    @seller&.seller_stripe_subscription&.reload
  end

end
