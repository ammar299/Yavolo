module SubscriptionPlans
  class SubscriptionPlanDestroyer < ApplicationService
    include Admin::SubscriptionsHelper
    attr_reader :status, :errors, :params

    def initialize(params)
      @params = params
      @errors = []
    end

    def call
      begin
        destroy_subscription_plan
      rescue StandardError => e
        @status = false
        @errors << e.message
      end
      self
    end

    private
    def destroy_subscription_plan
      if plan_has_subscription?(plan.plan_id)
        @errors << "You cannot delete this plan because subscriptions are/were associated with this plan."
      else
        delete_plan
      end
    end

    def delete_plan
      plan_delete = Stripe::Plan.delete(plan.plan_id)
      delete_product if plan_delete.deleted?
    end

    def delete_product
      product = Stripe::Product.delete(plan.plan_name_id)
      plan.destroy if product.deleted?
    end

    def seller
      @seller ||= params[:seller]
    end

    def plan
      @plan ||= SubscriptionPlan.where(id: @params[:params][:plan].to_i)&.last
    end

  end
end