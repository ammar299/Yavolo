module Sellers

  class StripeApiCallsService < ApplicationService
    def initialize()
    end

    def call(*args)
    end

    def self.set_card_as_default_payment(seller,card)
      Stripe::Customer.update(
        seller.stripe_customer.customer_id,
        {
          default_source: card.card_id,
        }
      )
    end
    
    def self.attach_card_to_customer(seller,stripe_token)
      Stripe::Customer.create_source(
        seller.stripe_customer.customer_id,
        {
          source:  stripe_token,
        }
      )
    end

    def self.retrieve_token(stripe_token)
      token = Stripe::Token.retrieve(
        stripe_token,
      )
      return token
    end

    def self.detach_card(token,seller)
      card = Stripe::Customer.delete_source(
        seller.stripe_customer.customer_id,
        token.card.id,
      )
      return card
    end
    
  end

end