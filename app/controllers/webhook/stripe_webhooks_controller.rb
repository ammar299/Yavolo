class Webhook::StripeWebhooksController < ActionController::Base
  skip_before_action :verify_authenticity_token

  def subscription_start_webhook
    webhook_type = params[:type]
    begin
      case webhook_type
      when 'customer.subscription.created'
        # create_customer_subscription(params)
      when 'subscription_schedule.aborted'
        
      when 'subscription_schedule.canceled'
        cancel_params = params
        cancel_subscription_webhook(cancel_params)
      when 'subscription_schedule.completed'
        # completed_subscription_webhook
      when 'subscription_schedule.created'
        # created_subscription_webhook
      when 'subscription_schedule.expiring'

      when 'subscription_schedule.released'

      when 'subscription_schedule.updated'
        updated_subscription_webhook(params)
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
      subscription_canceled_at = Time.at(cancel_params[:data][:object][:canceled_at]).to_datetime
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
    subscription_canceled_at = Time.at(params[:data][:object][:canceled_at]).to_datetime
    subscription = SellerStripeSubscription.where(subscription_schedule_id: subscription_id)
    subscription.status = subscription_updated_status
    subscription.canceled_at = subscription_canceled_at
    subscription.plan_id = subscription_plan_id
    subscription.save
  end

  def update_status_subscription(subscription_id,subscription_updated_status)
    standard_subscription_id = params[:data][:object][:subscription]
    subscription_plan_id = params[:data][:object][:phases][0][:items][0][:price]
    current_period_start = Time.at(params[:data][:object][:current_phase][:start_date]).to_datetime
    current_period_end = Time.at(params[:data][:object][:current_phase][:end_date]).to_datetime
    subscription = SellerStripeSubscription.where(subscription_schedule_id: subscription_id).last
    subscription.status = subscription_updated_status
    subscription.plan_id = subscription_plan_id
    subscription.current_period_start = current_period_start
    subscription.current_period_end = current_period_end
    subscription.subscription_stripe_id = params[:data][:object][:subscription]
    subscription.save
  end

end