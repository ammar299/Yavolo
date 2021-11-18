module Admins
  module Sellers
    class SubscriptionUpdaterService < ApplicationService
      attr_reader  :seller, :status,:errors

      def initialize(seller:, status:)
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
          cancel_subscription
        when "12_month"
          change_seller_subscription_status
        when "24_month"
          change_seller_subscription_status
        when "lifetime"
          change_seller_subscription_status
        else
          errors = "Select appropriate option"
        end
      end

      def change_seller_subscription_status
        @seller.subscription_type = @status
        @seller.save
        return @status
      end
      
      def cancel_subscription
        sub = Stripe::SubscriptionSchedule.cancel(
          get_subscription_id(),
        )
        record =  update_current_subscription(sub) if sub.status == 'canceled'
        @status = sub.status
      end

      def get_subscription_id
        subscription_status = @seller.seller_stripe_subscription.status
        if subscription_status == "not_started"
          @subscription_id = @seller.seller_stripe_subscription.subscription_schedule_id
        else
          @subscription_id = @seller.seller_stripe_subscription.subscription_schedule_id
        end
        return @subscription_id
      end

      def update_current_subscription(sub)
        record = @seller&.seller_stripe_subscription.update(
          subscription_schedule_id: sub.id,
          subscription_stripe_id: sub.subscription,
          status: sub.status,
          canceled_at: Time.at(sub.canceled_at).to_datetime,
        )
        return true if record == true 
        # CancelSubscriptionEmailWorker.perform_async(@seller.email)
      end

    end
  end
end

