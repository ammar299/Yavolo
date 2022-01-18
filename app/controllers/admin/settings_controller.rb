class Admin::SettingsController < Admin::BaseController
  before_action :subscriptions_for_view, only: %i[subscription_listing create_subscription remove_subscriptions update_subscription]
  include SubscriptionPlanMethods
  include Admin::SubscriptionsHelper

  def subscription_listing
  end
  
  def create_subscription
    @response = SubscriptionPlans::SubscriptionPlanCreator.call(params.dup)
    if @response.errors.any?
      notice = "Process failed"
    else
      @subscription = SubscriptionPlan.new(create_sub(params,@response))
      notice = "Process failed"
      if @subscription.save
        @subscription.update_rolling_subscription_on_plan(params)
        notice = "Subscription Plan created."
      end
    end
    flash.now[:notice] = notice
  end

  def update_subscription
    notice = "Subscription plan not updated successfully."
    rephrase_default_status(params)
    @subscription = SubscriptionPlan.where(id: params[:id].to_i)&.last
    pre_sub_record_status = @subscription&.rolling_subscription
    pre_sub_record_months = @subscription&.subscription_months
    prev_plan_name_id = @subscription&.plan_name_id
    prev_plan_id = @subscription&.plan_id
    if updator_service_call_valid?(params,@subscription)
      @response = SubscriptionPlans::SubscriptionPlanCreator.call(params.dup)
      record_updated = @subscription.update(create_sub(params,@response))
      current_plan_name_id = @response&.params[:plan_name_id]&.id
      current_plan_id = @response&.params[:plan_id]&.id
      UpdateSellersSubscriptionWorker.perform_async(params.to_json,current_plan_id,prev_plan_id,prev_plan_name_id,pre_sub_record_status,pre_sub_record_months)
    else
      record_updated = @subscription&.update(update_sub(params))
      @subscription.update_rolling_subscription_on_plan(params) if record_updated
      notify_associated_sellers(@subscription)
    end
    notice = "Subscription plan updated successfully." if @subscription.present? && record_updated
    flash.now[:notice] = notice
  end

  def remove_subscriptions
    @response = SubscriptionPlans::SubscriptionPlanDestroyer.call({params: params})
    notice = "Plan deleted successfully."
    if @response&.errors.any?
      notice = @response&.errors[0]
    end
    flash.now[:notice] = notice
  end

  def check_subscription_presence
    is_valid = "true"
    @sub = SubscriptionPlan.where('lower(subscription_name) = ?', params[:subscription_name].downcase)&.last
    already_present = SubscriptionPlan.where(id: params[:sub_id].to_i)&.last if params[:sub_id].present?
    if @sub.present?
      if already_present.present? && params[:subscription_name].downcase == already_present.subscription_name.downcase
        is_valid = "true"
      else
        is_valid = "false"
      end
    end
    render json: is_valid
  end

  private
  def create_sub(params,response)
    {
      subscription_name: params[:subscription_name],
      price: params[:subscription_price],
      commission_excluding_vat: params[:commission_excluding_vat],
      subscription_months: params[:subscription_months],
      rolling_subscription: params[:rolling_subscription],
      default_subscription: set_default_plan(params),
      plan_name_id: response&.params[:plan_name_id]&.id,
      plan_id:  response&.params[:plan_id]&.id
    }
  end

  def update_sub(params)
    {
      commission_excluding_vat: params[:commission_excluding_vat],
      subscription_months: params[:subscription_months],
      rolling_subscription: params[:rolling_subscription],
      default_subscription: set_default_plan(params)
    }
    
  end

  def subscriptions_for_view
    @subscriptions = SubscriptionPlan.all.order(created_at: :desc)
  end

  def notify_associated_sellers(plan)
    SellerStripeSubscription.all.each do |subscription|
      begin
        if subscription.plan_id == plan.plan_id
          notify_through_email(subscription.seller.email,"subscription_updated")
        end
      rescue
      end
    end
  end
end
