module Admins
  module Sellers
    class SubscriptionRenewService < ApplicationService
      include Admin::SubscriptionsHelper
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
        elsif @subscription.present? && @subscription.status == "canceled"
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
        update_current_subscription(sub) if sub.status == 'active'
      end

      def update_current_subscription(sub)
        record = @seller&.seller_stripe_subscription.update(update_params(sub))
      end

      def update_params(sub)
        {
          subscription_stripe_id: sub.id,
          status: sub.status,
          cancel_at_period_end: false,
          current_period_end: date_parser(sub.current_period_end),
          current_period_start: date_parser(sub.current_period_start),
          seller_requested_cancelation: false
        }
      end
    end
  end
end

