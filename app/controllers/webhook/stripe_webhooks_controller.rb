class Webhook::StripeWebhooksController < ActionController::Base
  include Admin::SubscriptionsHelper
  include SubscriptionPlanMethods
  skip_before_action :verify_authenticity_token

  def subscription_start_webhook
    webhook_type = params[:type]
    begin
      case webhook_type
      when 'customer.subscription.deleted','customer.subscription.updated'
        update_current_subscription_webhook(params)
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

  def update_invoice(params)
    bill = BillingListingStripe.where(invoice_id: params[:data][:object][:id])&.last
    if bill.present?
      bill.update(update_invoice_paranms(params))
    else
      customer = StripeCustomer.where(customer_id: params[:data][:object][:customer])&.last
      invoice  = customer.try(:stripe_customerable).try(:billing_listing_stripe).create(create_invoice_params(params)) if customer.present?
      pay_invoice(params)
    end
  end

  def pay_invoice(params)
    begin
      Stripe::Invoice.pay(params[:data][:object][:id])
    rescue
    end
  end

  def create_invoice_params(params)
    {
      invoice_id: params[:data][:object][:id],
      total: params[:data][:object][:total].to_f,
      description: params[:data][:object][:lines][:data].last[:description],
      date_generated: date_parser(params[:data][:object][:created]),
      due_date: date_parser(params[:data][:object][:due_date]),
      status:  params[:data][:object][:status]
    }
  end

  def update_invoice_paranms(params)
    {
      status: params[:data][:object][:status]
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

  def update_current_subscription_webhook(params)
    subscription_id = params[:data][:object][:id]
    subscription = SellerStripeSubscription.where(subscription_stripe_id: subscription_id)&.last
    subscription.update(update_params(params)) if subscription.present?
    if params[:data][:object][:status] == "canceled"
      subscription.update(cancel_after_next_payment_taken: false)
    end
  end

  def update_params(params)
    {  
      status: params[:data][:object][:status],
      current_period_end: date_parser(params[:data][:object][:current_period_end]),
      current_period_start: date_parser(params[:data][:object][:current_period_start]),
      canceled_at: date_parser(params[:data][:object][:canceled_at]),
      cancel_at: date_parser(params[:data][:object][:cancel_at]),
      cancel_at_period_end: params[:data][:object][:cancel_at_period_end]
    }
  end

end