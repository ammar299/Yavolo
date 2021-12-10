module Admins
  module Sellers
    class SubscriptionUpdaterService < ApplicationService
      include Admin::SubscriptionsHelper
      attr_reader  :seller, :status, :errors

      def initialize(subscription_status,enforce_status,seller)
          @status = subscription_status
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
        case @status
        when "cancel"
          check_cancelation_process
        when "month_12"
          @start_date = Time.current + 3.minutes
          change_seller_subscription_status
        when "month_24"
          @start_date = Time.current + 2.year
          change_seller_subscription_status
        when "month_36"
          @start_date = Time.current + 3.year
          change_seller_subscription_status
        when "lifetime"
          @start_date = Time.current + 10.year
          change_seller_subscription_status
        else
          errors = "Select correct option"
        end
      end

      def check_cancelation_process
        if @seller&.seller_stripe_subscription&.status == "not_started"
          cancel_schedule_subscription
          set_cancel_status(false)
        elsif @seller&.seller_stripe_subscription&.status == "active" && @enforce_status == "next-payment-taken"
          @status = "already-set-to-cancel"
          if @seller&.seller_stripe_subscription&.cancel_after_next_payment_taken == false
            cancel_after_next_payment_subscription            
          end
        elsif @seller&.seller_stripe_subscription&.status == "active" && @enforce_status == "current-subscriptions-end"
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
        @seller&.seller_stripe_subscription&.update(cancel_after_next_payment_taken: status)
      end

      def run_at
        begin
          date_parser(retrieve_scheduled_subscription&.current_phase&.end_date) + 2.hours
        rescue
          date_parser(retrieve_released_subscription.current_period_end) + 2.hours
        end
      end

      def retrieve_released_subscription
        Stripe::Subscription.retrieve(
          @seller&.seller_stripe_subscription&.subscription_stripe_id,
        )
      end

      def retrieve_scheduled_subscription
        Stripe::SubscriptionSchedule.retrieve(
          get_subscription_id,
        )
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
              price: sub_id.plan_id,
              quantity: 1,
            },
          ],
            start_date: @start_date.to_i
            },
          ],
        )
        update_schedule_subscription_db(sub)
      end

      def cancel_schedule_subscription
        sub = Stripe::SubscriptionSchedule.cancel(
          get_subscription_id,
        )
        record =  update_current_schedule_subscription(sub) if sub.status == 'canceled'
        @status = sub.status
      end

      def release_schedule_subscription
        begin
          release = Stripe::SubscriptionSchedule.release(
            get_subscription_id,
          )
          return release
        rescue
          return true
        end
      end

      def cancel_subscription
        release_schedule_subscription if !@seller.seller_stripe_subscription.cancel_at_period_end?
          @subscription_id = @seller.seller_stripe_subscription.subscription_stripe_id
          sub = Stripe::Subscription.update(
            @subscription_id,
              {
                cancel_at_period_end: true,
              }
            )
          record =  update_current_subscription(sub) if sub.status == 'active'
          @status = "canceled" if record == true
      end

      def update_schedule_subscription_db(sub)
        record = @seller&.seller_stripe_subscription&.update(
          schedule_date: date_parser(sub.phases[0].start_date)
        )
        true if record == true 
      end

      def get_subscription_id
        @seller&.seller_stripe_subscription&.subscription_schedule_id
      end

      def update_current_subscription(sub)
        record = @seller&.seller_stripe_subscription.update(
          subscription_stripe_id: sub.id,
          status: sub.status,
          cancel_at_period_end: sub.cancel_at_period_end || false,
          canceled_at: date_parser(sub.canceled_at),
          seller_requested_cancelation: false
        )
        UpdateSubscriptionEmailWorker.perform_async(@seller.email,"canceled_at_time_end")
        true if record == true 
      end

      def update_current_schedule_subscription(sub)
        record = @seller&.seller_stripe_subscription.update(
          subscription_schedule_id: sub.id,
          subscription_stripe_id: sub.subscription,
          status: sub.status,
          canceled_at: date_parser(sub.canceled_at),
          seller_requested_cancelation: false
        )
        UpdateSubscriptionEmailWorker.perform_async(@seller.email,"canceled_immediateley")
        true if record == true 
      end
    end
  end
end

