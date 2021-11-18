class Webhook::StripeWebhooksController < ActionController::Base
  skip_before_action :verify_authenticity_token

  def subscription_start_webhook
    webhook_type = params[:type]
    begin
      case webhook_type
      when 'subscription_schedule.aborted'
        
      when 'subscription_schedule.canceled'
        cancel_subscription_webhook
      when 'subscription_schedule.completed'
        # completed_subscription_webhook
      when 'subscription_schedule.created'
        # created_subscription_webhook
      when 'subscription_schedule.expiring'

      when 'subscription_schedule.released'

      when 'subscription_schedule.updated'
        updated_subscription_webhook
      else
          puts "Unhandled event type: #{webhook_type}"
      end
      status 200
    rescue JSON::ParserError => e
      # Invalid payload
      status 400
      return
    rescue Stripe::SignatureVerificationError => e
      # Invalid signature
      status 400
      return
    end

  end

  def cancel_subscription_webhook
    subscription_id = params[:data][:object][:subscription]
    subscription_updated_status = params[:data][:object][:status]
    subscription_plan_id = params[:data][:object][:phases][0][:items][0][:price]
    subscription_canceled_at = Time.at(params[:data][:object][:canceled_at]).to_datetime
    subscription = SellerStripeSubscription.where(subscription_schedule_id: subscription_id)
    if subscription.present?
      subscription.status = subscription_updated_status
      subscription.canceled_at = subscription_canceled_at
      subscription.plan_name = subscription_plan_id
      subscription.save
    end
  end

  def updated_subscription_webhook
    subscription_id = params[:data][:object][:id]
    subscription_updated_status = params[:data][:object][:status]
    if subscription_updated_status == "active"
      update_status_subscription(subscription_id,subscription_updated_status)
    else

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
    subscription.plan_name = subscription_plan_id
    subscription.save
  end

  private

  def update_status_subscription(subscription_id,subscription_updated_status)
    subscription_plan_id = params[:data][:object][:phases][0][:items][0][:price]
    current_period_start = Time.at(params[:data][:object][:current_phase][:start_date]).to_datetime
    current_period_end = Time.at(params[:data][:object][:current_phase][:end_date]).to_datetime
    subscription = SellerStripeSubscription.where(subscription_schedule_id: subscription_id).last
    subscription.status = subscription_updated_status
    subscription.plan_name = subscription_plan_id
    subscription.current_period_start = current_period_start
    subscription.current_period_end = current_period_end
    subscription.save
  end

end