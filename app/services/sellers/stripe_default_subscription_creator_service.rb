module Sellers

  class StripeDefaultSubscriptionCreatorService < ApplicationService
    attr_reader :seller, :errors
    def initialize(seller:)
      @seller = seller
      @errors = []
    end

    def call(*args)
      begin
        get_stripe_customer
        get_stripe_default_plan
        schedule_subscription_api
        create_subscription_in_database
        self
      rescue => exception
        @errors << exception
      end
    end

    def get_stripe_customer
      if @seller&.stripe_customer.present?
        @stripe_customer = @seller.stripe_customer.customer_id
      else
        @stripe_customer = Sellers::StripeCustomerService.call({seller: current_seller})
      end
    end
    
    def get_stripe_default_plan
      @default_plan = Stripe::Price.retrieve(
        'price_1JwNfWFqSiWsjxhXYj4fvz6f',
      )
    end

    def get_start_date
      if @seller.subscription_type == "monthly"
        @start_date = Time.current #1731016200
      elsif @seller.subscription_type == "yearly"
        @start_date = Time.current+1.year
      end
      return @start_date
    end

    def schedule_subscription_api
      subsciption_type = get_start_date()
      @subscription_schedule = Stripe::SubscriptionSchedule.create({
        customer: @stripe_customer,
        start_date: subsciption_type.to_i,
        end_behavior: 'release',
        phases: [
          {
            items: [
              {
                price: @default_plan.id,
                quantity: 1,
              },
            ],
          },
        ],
      })
    end

    def create_subscription_in_database
      if @subscription_schedule.present?
        @seller&.create_seller_stripe_subscription(
          subscription_schedule_id: @subscription_schedule.id,
          subscription_stripe_id: @subscription_schedule.subscription,
          plan_name: @subscription_schedule.phases[0].items[0].plan,
          status: @subscription_schedule.status,
          canceled_at: @subscription_schedule.canceled_at,
          current_period_end: @subscription_schedule.phases[0].start_date,
          current_period_start: @subscription_schedule.phases[0].end_date,
          customer: @subscription_schedule.customer,
          default_payment_method: @subscription_schedule.phases[0].default_payment_method,
        )
      end
    end
    
    def update_current_subscription
      if @subscription_schedule.present?
        @seller&.seller_stripe_subscription.update(
          subscription_schedule_id: @subscription_schedule.id,
          subscription_stripe_id: @subscription_schedule.subscription,
          plan_name: @subscription_schedule.phases[0].items[0].plan,
          status: @subscription_schedule.status,
          canceled_at: @subscription_schedule.canceled_at,
          current_period_end: @subscription_schedule.phases[0].start_date,
          current_period_start: @subscription_schedule.phases[0].end_date,
          customer: @subscription_schedule.customer,
          default_payment_method: @subscription_schedule.phases[0].default_payment_method,
        )
      end
    end
    
  end

end