module Admin::SubscriptionsHelper

  def plan_name
    seller_subscription&.plan_name || "Default"
  end

  def subscription_name
    value = "Standard"
    if @seller.provider == "admin" && @seller.subscription_type == "month_12"
      value = "12 Month"
    elsif @seller.provider == "admin" && @seller.subscription_type == "month_24"
      value = "24 Month"
    elsif @seller.provider == "admin" && @seller.subscription_type == "month_36"
      value = "36 Month"
    elsif @seller.provider == "admin" && @seller.subscription_type == "lifetime"
      value = "Pioneer"
    end
    value
  end

  def expiry_date
    value = seller_subscription&.schedule_date&.strftime('%d/%m/%y %T') || seller_subscription&.current_period_end&.strftime('%d/%m/%y %T') || ""
    if subscription_name == "Standard"
      value = seller_subscription&.current_period_end&.strftime('%d/%m/%y %T') || seller_subscription&.schedule_date&.strftime('%d/%m/%y %T') || ""
    end
    value
  end

  def renewal_cost
    val = "£0.00"
    if @seller.provider != "admin"
    val = "£29.00"
    end
    val
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
    seller_subscription&.canceled_at&.strftime('%d/%m/%y %T') 
  end

  def seller_requested_cancelation?
    @seller.seller_stripe_subscription.seller_requested_cancelation
  end

  def is_eligible_for_save?
    (seller_subscription.present? && cancel_at_period_end_nil_or_false? && !cancel_after_next_payment_taken? && !subscription_canceled?)
  end
  
  def seller_subscription
    @seller&.seller_stripe_subscription&.reload
  end

  def date_parser(date)
    begin 
      Time.at(date)
    rescue
      nil
    end
  end

end
