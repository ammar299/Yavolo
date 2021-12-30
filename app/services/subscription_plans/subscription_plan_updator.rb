module SubscriptionPlans
  class SubscriptionPlanUpdator < ApplicationService
    include Admin::SubscriptionsHelper
    attr_reader :status, :errors, :params

    def initialize(params)
      @params = params
      @errors = []
    end

    def call
      begin
        update_subscription_plan
      rescue StandardError => e
        @status = false
        @errors << e.message
      end
      self
    end

    private
    def update_subscription_plan
      if @params[:subscription_price]&.to_f == subscription&.price&.to_f
        @params[:plan_id] = Stripe::Price.update(subscription.plan_id,update_name_params)
      else
        @params[:plan_id] = Stripe::Price.create(create_plan_params)
      end
    end

    def stripe_product
      if subscription.subscription_name == subscription_name_current
        @params[:plan_name_id] = product_plan_id
      else
        @params[:plan_name_id] = Stripe::Product.create(product_param)&.id
      end
    end

    def product_param
      {
        name: subscription_name_current
      }
    end

    def create_plan_params
      {
        unit_amount:  subscription_price,
        product: stripe_product,
      }
    end

    def update_name_params
      {
        product: stripe_product,
      }
    end

    def subscription_name_current
      @params[:subscription_name]
    end

    def seller
      @seller ||= params[:seller]
    end

    def subscription_price
      (@params[:subscription_price]&.to_f * 100)&.to_i
    end

    def subscription
      @subscription ||= Subscription.where(id: @params[:id]&.to_i)&.last
    end

    def product_plan_id
      @product_plan_id ||= subscription.plan_name_id
    end

  end
end
