  class StripeDefaultSubscriptionCreatorService < ApplicationService
    include Admin::SubscriptionsHelper
    include SubscriptionPlanMethods
    attr_reader :params, :errors
    def initialize(params)
      @params = params
      @errors = []
    end

    def call(*args)
      begin
        if current_default_plan(seller).present?
          subscribe_seller
          create_subscription_in_database
        end
        self
      rescue => exception
        @errors << exception
      end
    end

    def get_stripe_customer
      if seller&.stripe_customer.present?
        @stripe_customer = seller.stripe_customer.customer_id
      else
        @stripe_customer = Sellers::StripeCustomerService.call({seller: seller})
      end
    end
    
    def subscribe_seller
      if current_default_plan(seller).rolling_subscription != "on"
        @subscription = Stripe::Subscription.create(subscription_create(current_default_plan(seller), 'off'))
      else
        @subscription = Stripe::Subscription.create(subscription_create(current_default_plan(seller), 'on'))
      end
    end

    def subscription_create(default_plan,type)
      val = { customer: get_stripe_customer,
        items: [
            {price: default_plan.plan_id},
          ],
        }
      val.merge(cancel_at: time_to_cancel(default_plan)) if type == 'off'
      val
    end

    def create_subscription_in_database
      if @subscription.present?
        if seller_subscription.present?
          seller_subscription.update(subscription_params(@subscription,seller))
        else
          seller&.create_seller_stripe_subscription(subscription_params(@subscription,seller))
        end
        seller.update(subscription_type: default_plan.subscription_name)
      end
    end
    
    private

    def seller
      @seller ||= params[:seller]
    end

    def seller_subscription
      @seller_subscription ||= seller&.seller_stripe_subscription
    end

    def time_to_cancel(default_plan)
      value = Time.now + default_plan.subscription_months.to_i.months
    end

  end