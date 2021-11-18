module Sellers

  class StripeCustomerService < ApplicationService
    attr_reader :params
    
    def initialize(params)
      @params = params
    end

    def call(*args)
      create_stripe_customer
    end

    def create_stripe_customer
      @customer = Stripe::Customer.create({
        description: "This subscription is subscribed by default on seller sign up",
        email: seller.email,
      })
      create_customer_in_database
      return @customer.id
    end
    
    def create_customer_in_database
      @stripe_customer = seller&.create_stripe_customer!(
        customer_id: @customer.id,
        email: @customer.email,
      )
    end

    private
    def seller
      @seller ||=params[:seller] 
    end
  end

end