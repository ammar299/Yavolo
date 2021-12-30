module SubscriptionPlans
  class SubscriptionPlanCreator < ApplicationService
    attr_reader :status, :errors, :params

    def initialize(params)
      @params = params
      @errors = []
    end

    def call
      begin
        create_subscription_plan
      rescue StandardError => e
        @status = false
        @errors << e.message
      end
      self
    end

    private
    def create_subscription_plan
      @params[:plan_id] = Stripe::Price.create(plan_params)
    end

    def create_stripe_product
      @params[:plan_name_id] = Stripe::Product.create(product_param)
    end

    def product_param
      {
        name: subscription_name
      }
    end

    def plan_params
      {
        unit_amount:  subscription_price.to_s,
        currency: 'gbp',
        recurring: {interval: 'month'},
        product: create_stripe_product.id,
      }
    end

    def subscription_name
      @params[:subscription_name]
    end

    def seller
      @params[:seller]
    end

    def subscription_price
      @price ||= (@params[:subscription_price]&.to_f * 100).to_i
    end

  end
end
