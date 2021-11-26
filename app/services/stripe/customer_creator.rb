require 'stripe'
module Stripe
  # This service is to create a stripe customer from token
  class CustomerCreator < ApplicationService
    attr_reader :status, :errors, :params, :response

    def initialize(params)
      super()
      @params = params
      @status = true
      @errors = []
      @response = nil
    end

    def call
      begin
        @response = create_or_update_customer_on_stripe
      rescue StandardError => e
        @status = false
        @errors << e.message
      end
      self
    end

    private

    def create_or_update_customer_on_stripe
      if stripe_customer_id.present?
        update_customer_source(find_customer(stripe_customer_id))
      else
        create_customer
      end
    end

    def find_customer(stripe_customer_id)
      Stripe::Customer.retrieve(stripe_customer_id)
    end

    def create_customer
      Stripe::Customer.create({ email: buyer.email, source: stripe_token_id })
      # save_customer_detail(customer) if customer.present?
      # customer
    end

    def save_customer_detail(customer)
      if buyer.stripe_customer.present?
        buyer.stripe_customer.update_column(customer_id: customer.id)
      else
        buyer.create_stripe_customer(customer_id: customer.id)
      end
    end

    def update_customer_source(customer)
      customer_source = attach_source(customer, stripe_token_id)
      Stripe::Customer.update(customer.id, { default_source: customer_source[:id] })
    end

    def attach_source(customer, stripe_token_id)
      Stripe::Customer.create_source(
        customer.id,
        {
          source: stripe_token_id
        }
      )
    end

    def stripe_token_id
      params[:stripe_token_id]
    end

    def buyer
      params[:buyer] || nil
    end

    def stripe_customer_id
      buyer.stripe_customer.customer_id if buyer.stripe_customer.present?
    end
  end
end
