module Admins
  module Sellers
    class SubscriptionRenewService < ApplicationService
      attr_reader  :seller, :status, :errors

      def initialize(seller)
          @seller = seller
          @errors = []
      end


      def call
        begin
          check_status_for_renewal
        rescue StandardError => e
          @errors << e.message
        end
        self
      end

      private

      def check_status_for_renewal
        @subscription = @seller.seller_stripe_subscription
        if @subscription.present? && @subscription.cancel_at_period_end == true
          renew_seller_subscription
        elsif @subscription.present? && @subscription.status == "canceled" && (@subscription.cancel_at_period_end.nil? || !@subscription.subscription_stripe_id.present?)
          @seller.seller_stripe_subscription.destroy
          @subscribe = Admins::Sellers::SubscriptionNewCreatorService.call({seller: @seller})
          if @subscribe.errors.present?
            @errors << @subscribe.errors
          end
        end
      end

      def renew_seller_subscription
        @subscription = @seller.seller_stripe_subscription
        sub = Stripe::Subscription.update(
          @subscription.subscription_stripe_id,
            {
              cancel_at_period_end: false,
            }
          )
        record =  update_current_subscription(sub) if sub.status == 'active'
      end

      def update_current_subscription(sub)
        record = @seller&.seller_stripe_subscription.update(
          subscription_schedule_id: sub.id,
          status: sub.status,
          cancel_at_period_end: false,
          current_period_end: sub.current_period_end,
          current_period_start: sub.current_period_start,
          seller_requested_cancelation: false
        )
        
        return true if record == true 
      end

    end
  end
end

