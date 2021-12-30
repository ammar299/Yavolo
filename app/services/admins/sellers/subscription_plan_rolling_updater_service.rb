module Admins
  module Sellers
    class SubscriptionPlanRollingUpdaterService < ApplicationService
      attr_reader  :seller, :status, :errors

      def initialize(subscription,rolling_months,rolling_status)
          @subscription = subscription
          @rolling_months = rolling_months
          @rolling_status = rolling_status
          @errors = []
      end


      def call
        begin
          update_cancel_date
        rescue StandardError => e
          @errors << e.message
        end
        self
      end

      private
      def update_cancel_date
        if @rolling_status == true
          update_rolling_to_unlimited
        else
          update_rolling_to_limited
        end
      end
    
      def update_rolling_to_unlimited
        Stripe::Subscription.update(
          @subscription.subscription_stripe_id,
            {
               cancel_at_period_end: false,
             }
         )
      end
    
      def update_rolling_to_limited
        Stripe::Subscription.update(
          @subscription.subscription_stripe_id,
          cancel_at: time_stamp(@rolling_months.to_i.months).to_i
        )
      end
    
      def time_stamp(interval)
        Time.now + interval
      end
    
    end
  end
end

