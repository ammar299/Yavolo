module Admins
  module Sellers
    class SubscriptionUpdaterService < ApplicationService
      attr_reader  :seller, :status, :errors

      def initialize(status,seller)
          @status = status
          @seller = seller
          @errors = []
      end


      def call
        begin
          check_request_status
        rescue StandardError => e
          @errors << e.message
        end
        self
      end

      private
      def check_request_status
        case @status
        when "cancel"
          if @seller.seller_stripe_subscription.status == "not_started"
            cancel_schedule_subscription
          else
            cancel_subscription
          end
        when "12_month"
          @start_date = @seller.seller_stripe_subscription.schedule_date.to_datetime + 1.year
          @status = "month_12"
          change_seller_subscription_status
        when "24_month"
          @start_date = @seller.seller_stripe_subscription.schedule_date.to_datetime + 2.year
          @status = "month_24"
          change_seller_subscription_status
        when "36_month"
          @start_date = @seller.seller_stripe_subscription.schedule_date.to_datetime + 3.year
          @status = "month_36"
          change_seller_subscription_status
        when "lifetime"
          change_seller_subscription_status
        else
          errors = "Select appropriate option"
        end
      end

      def change_seller_subscription_status
        update_schedule_subscription
        @seller.subscription_type = @status
        @seller.save
        return @status
      end

      def update_schedule_subscription
        sub_id = @seller.seller_stripe_subscription
        sub = Stripe::SubscriptionSchedule.update(
          "#{sub_id.subscription_schedule_id}",
        phases: [
            {
          items: [
            {
              price: sub_id.plan_name,
              quantity: 1,
            },
          ],
            start_date: @start_date.to_i
            },
          ],
        )
        update_schedule_subscription(sub)
      end

      def cancel_schedule_subscription
        sub = Stripe::SubscriptionSchedule.cancel(
          get_subscription_id(),
        )
        record =  update_current_subscription(sub) if sub.status == 'canceled'
        @status = sub.status
      end

      def release_schedule_subscription
        release = Stripe::SubscriptionSchedule.release(
          get_subscription_id(),
        )
        return release
      end

      def cancel_subscription
        release = release_schedule_subscription()
        if release.status =="released"
          @subscription_id = @seller.seller_stripe_subscription.subscription_stripe_id
          sub = Stripe::Subscription.update(
            @subscription_id,
              {
                cancel_at_period_end: true,
              }
            )
          record =  update_current_subscription(sub) if sub.status == 'active'
          @status = sub.status
        end
      end

      def update_schedule_subscription(sub)
        record = @seller&.seller_stripe_subscription.update(
          schedule_date: sub.phases[0].start_date
        )
        return true if record == true 
      end

      def get_subscription_id
        @subscription_id = @seller.seller_stripe_subscription.subscription_schedule_id
        return @subscription_id
      end

      def update_current_subscription(sub)
        record = @seller&.seller_stripe_subscription.update(
          subscription_schedule_id: sub.id,
          subscription_stripe_id: sub.subscription,
          status: sub.status,
          cancel_at_period_end: sub.cancel_at_period_end,
          canceled_at: Time.at(sub.canceled_at).to_datetime,

        )
        return true if record == true 
        # CancelSubscriptionEmailWorker.perform_async(@seller.email)
      end

    end
  end
end

