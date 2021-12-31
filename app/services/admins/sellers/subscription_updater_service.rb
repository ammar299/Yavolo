module Admins
  module Sellers
    class SubscriptionUpdaterService < ApplicationService
      include Admin::SubscriptionsHelper
      include SubscriptionPlanMethods
      attr_reader  :seller, :status, :errors

      def initialize(subscription_status,enforce_status,seller)
        @subscription_plan = subscription_status
        @enforce_status = enforce_status
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
        if @subscription_plan == "cancel"
          check_cancelation_process
        elsif @subscription_plan != "cancel" && @subscription_plan != seller_current_subscription.plan_id
          change_seller_subscription_status
        elsif @subscription_plan != "cancel" && @subscription_plan == seller_current_subscription.plan_id
          return @status = "already_set"
        end
      end

      def check_cancelation_process
        if seller_current_subscription.status == "active" && @enforce_status == "next-payment-taken"
          @status = "already-set-to-cancel"
          cancel_after_next_payment_subscription  if seller_current_subscription&.cancel_after_next_payment_taken == false         
        elsif seller_current_subscription&.status == "active" && @enforce_status == "current-subscriptions-end"
          cancel_subscription
          set_cancel_status(false)
        end
      end

      def cancel_after_next_payment_subscription
        begin
          set_cancel_status(true)
          Admins::Sellers::DeleteSpecificWrokerService.call(@seller)
          worker = CancelSubscriptionAfterPaymentTakenWorker.perform_at(run_at, @seller.id)
          update_worker(worker)
          @status = "after-next-payment-taken"
        rescue => e
          set_cancel_status(false)
          @errors << e.message
        end
      end

      def update_worker(worker)
        @seller&.seller_stripe_subscription&.update(associated_worker: worker)
      end

      def set_cancel_status(status)
        seller_current_subscription&.update(cancel_after_next_payment_taken: status)
      end

      def run_at
        begin
          date_parser(seller_current_subscription.current_period_end) + 2.hours
        rescue => e
          @errors << e.message
        end
      end

      def change_seller_subscription_status
        if new_plan.rolling_subscription == "on"
          sub  = update_stripe_subscription_to_active(seller_current_subscription,@subscription_plan)
        else
          sub  = update_stripe_subscription(seller_current_subscription,@subscription_plan)
        end
        if sub.present?
          sub_deleted = delete_prev_plan_from_subscription(sub)
          seller_current_subscription.update(stripe_params(new_plan.subscription_name,sub)) if sub_deleted.deleted?
        end
        @seller.update(subscription_type: new_plan.subscription_name)
        return @status = "other"
      end

      def cancel_subscription
        sub = Stripe::Subscription.update(
          seller_current_subscription.subscription_stripe_id,
            {
              cancel_at_period_end: true,
            }
          )
        record =  update_current_subscription(sub) if sub.status == 'active'
        @status = "canceled" if record == true
      end

      def get_subscription_id
        @seller&.seller_stripe_subscription&.subscription_schedule_id
      end

      def update_current_subscription(sub)
        record = seller_current_subscription.update(
          status: sub.status,
          cancel_at_period_end: sub.cancel_at_period_end || false,
          canceled_at: date_parser(sub.canceled_at),
          seller_requested_cancelation: false
        )
        true if record == true 
      end

      def update_current_subscription_db(sub)
        record = seller_current_subscription.update(subscription_params(sub,@seller))
        true if record == true 
      end

      def seller_current_subscription
        @seller_sub ||= @seller&.seller_stripe_subscription
      end

      def new_plan
        SubscriptionPlan.where(plan_id: @subscription_plan)&.last
      end

    end
  end
end

