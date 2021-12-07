class Webhook::StripeWebhooksController < ActionController::Base
  include Admin::SubscriptionsHelper
  skip_before_action :verify_authenticity_token

  def subscription_start_webhook
    webhook_type = params[:type]
    begin
      case webhook_type
      when 'customer.subscription.created'
        # create_customer_subscription(params)
      when 'subscription_schedule.aborted'

      when 'customer.subscription.deleted'
        cancel_current_subscription_webhook(params)
      when 'subscription_schedule.canceled'
        cancel_subscription_webhook(params)
      when 'subscription_schedule.completed'
        # completed_subscription_webhook
      when 'subscription_schedule.created'
        # created_subscription_webhook
      when 'subscription_schedule.expiring'

      when 'subscription_schedule.released'

      when 'subscription_schedule.updated'
        updated_subscription_webhook(params)
      when 'account.updated'
        account_updated(params)
      when check_invoice_status[check_invoice_status.index(webhook_type)]
        update_invoice(params)
      else
          puts "Unhandled event type: #{webhook_type}"
      end

      return :ok
    rescue JSON::ParserError => e
      # Invalid payload
      return :status => 400
    rescue Stripe::SignatureVerificationError => e
      # Invalid signature
      return :status => 400
    end

  end

  private
  def check_invoice_status
    ['invoice.created','invoice.updated','invoice.deleted','invoice.finalization_failed',
      'invoice.finalized','invoice.marked_uncollectible','invoice.paid','invoice.payment_action_required',
        'invoice.payment_failed','invoice.payment_succeeded','invoice.sent','invoice.upcoming','invoice.voided']
  end

  def update_invoice(params)
    bill = BillingListingStripe.where(invoice_id: params["data"]["object"]["id"])&.last
    if bill.present?
      bill.update(update_invoice_paranms(params))
    else
      customer = StripeCustomer.where(customer_id: params["data"]["object"]["customer"])&.last
      invoice  = customer.try(:stripe_customerable).try(:billing_listing_stripe).create(create_invoice_params(params)) if customer.present?
      pay_invoice(params)
    end
  end

  def pay_invoice(params)
    begin
      Stripe::Invoice.pay(params["data"]["object"]["id"])
    rescue
    end
  end

  def create_invoice_params(params)
    {
      invoice_id: params["data"]["object"]["id"],
      total: params["data"]["object"]["total"].to_f,
      description: params["data"]["object"]["lines"]["data"][0]["description"],
      date_generated: date_parser(params["data"]["object"]["created"]),
      due_date: date_parser(params["data"]["object"]["due_date"]),
      status:  params["data"]["object"]["status"]
    }
  end

  def update_invoice_paranms(params)
    {
      status: params["data"]["object"]["status"]
    } 
  end

  def account_updated(params)
    begin
      bank_detail = BankDetail.find_by(customer_stripe_account_id: params[:data][:object][:id].to_i)
      if bank_detail.present?
        bank_detail.account_verification_status = params[:data][:object][:payouts_enabled]
        bank_detail.save
      end
    rescue
    end
  end

  def create_customer_subscription(params)
  end

  def cancel_subscription_webhook(cancel_params)
    subscription_id = cancel_params[:data][:object][:subscription]
    subscription_schedule_id = cancel_params[:data][:object][:id]
    subscription = SellerStripeSubscription.find_by(subscription_stripe_id: subscription_id)
    subscription = SellerStripeSubscription.find_by(subscription_schedule_id: subscription_schedule_id) if !subscription.present?
    if subscription.present?
      subscription_updated_status = cancel_params[:data][:object][:status]
      subscription_plan_id = cancel_params[:data][:object][:phases][0][:items][0][:price]
      subscription_canceled_at = date_parser(cancel_params[:data][:object][:canceled_at])
      subscription.status = "canceled"  #subscription_updated_status
      subscription.canceled_at = subscription_canceled_at
      subscription.plan_id = subscription_plan_id
      subscription.save
    end
    return true
  end

  def updated_subscription_webhook(params)
    subscription_id = params[:data][:object][:id]
    subscription_updated_status = params[:data][:object][:status]
    if subscription_updated_status == "active"
      update_status_subscription(subscription_id,subscription_updated_status)
    end
  end

  def completed_subscription_webhook
    subscription_id = params[:data][:object][:id]
    subscription_updated_status = params[:data][:object][:status]
    subscription_plan_id = params[:data][:object][:phases][0][:items][0][:price]
    subscription_canceled_at = date_parser(params[:data][:object][:canceled_at])
    subscription = SellerStripeSubscription.where(subscription_schedule_id: subscription_id)
    subscription.status = subscription_updated_status
    subscription.canceled_at = subscription_canceled_at
    subscription.plan_id = subscription_plan_id
    subscription.save
  end

  def update_status_subscription(subscription_id,subscription_updated_status)
    standard_subscription_id = params[:data][:object][:subscription]
    subscription_plan_id = params[:data][:object][:phases][0][:items][0][:price]
    current_period_start = date_parser(params[:data][:object][:current_phase][:start_date])
    current_period_end = date_parser(params[:data][:object][:current_phase][:end_date])
    subscription = SellerStripeSubscription.where(subscription_schedule_id: subscription_id).last
    subscription.status = subscription_updated_status
    subscription.plan_id = subscription_plan_id
    subscription.current_period_start = current_period_start
    subscription.current_period_end = current_period_end
    subscription.subscription_stripe_id = params[:data][:object][:subscription]
    subscription.save
  end

  def cancel_current_subscription_webhook(params)
    subscription_id = params[:data][:object][:id]
    subscription = SellerStripeSubscription.where(subscription_stripe_id: subscription_id)&.last&.update(update_params(params))
  end

  def update_params(params)
    {
      status: params[:data][:object][:status],
      current_period_end: date_parser(params[:data][:object][:current_period_start]),
      current_period_start: date_parser(params[:data][:object][:current_period_end]),
      cancel_at_period_end: params[:data][:object][:cancel_at_period_end]
    }
  end

end