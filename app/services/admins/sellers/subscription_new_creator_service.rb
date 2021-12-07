module Admins
  module Sellers

    class SubscriptionNewCreatorService < ApplicationService
      include Admin::SubscriptionsHelper
      attr_reader :params, :errors
      def initialize(params)
        @params = params
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
        if seller&.stripe_customer.present?
          @stripe_customer = seller.stripe_customer.customer_id
        else
          @stripe_customer = Sellers::StripeCustomerService.call({seller: seller})
        end
      end
      
      def get_stripe_default_plan
        @default_plan = Stripe::Price.retrieve(
          'price_1K1QWhFqSiWsjxhXvi9luwKW',
        )
      end

      def get_start_date
        if @seller.provider == "admin" && (@seller.subscription_type == "month_12" || @seller.subscription_type == "month_24" || @seller.subscription_type == "month_36" || @seller.subscription_type == "lifetime")
          case seller.subscription_type
          when "month_12"
            @start_date = Time.current + 1.year
          when "month_24"
            @start_date = Time.current + 2.year
          when "month_36"
            @start_date = Time.current + 3.year
          when "lifetime"
            @start_date = Time.current + 10.year
          end
        else
          @start_date = Time.current
        end
        return @start_date
      end

      def schedule_subscription_api
        subsciption_start_date = get_start_date()
        @subscription_schedule = Stripe::SubscriptionSchedule.create({
          customer: @stripe_customer,
          start_date: subsciption_start_date.to_i,
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

      def get_product_name
        @default_product = Stripe::Product.retrieve(
          @default_plan.product,
        )
      end

      def create_subscription_in_database
        @seller.seller_stripe_subscription.destroy if @seller&.seller_stripe_subscription.present?
        get_product_name
        if @subscription_schedule.present?
          seller&.create_seller_stripe_subscription(
            subscription_schedule_id: @subscription_schedule.id,
            subscription_stripe_id: @subscription_schedule.subscription,
            plan_id: @subscription_schedule.phases[0].items[0].plan,
            status: @subscription_schedule.status,
            canceled_at: date_parser(@subscription_schedule.canceled_at),
            current_period_end: date_parser(@subscription_schedule.phases[0].start_date),
            current_period_start: date_parser(@subscription_schedule.phases[0].end_date),
            customer: @subscription_schedule.customer,
            schedule_date: date_parser(@subscription_schedule.phases[0].start_date),
            plan_name: @default_product.name,
            subscription_data: @subscription_schedule
          )
        end
      end
      
      private

      def seller
        @seller ||= params[:seller]
      end

    end

  end
end