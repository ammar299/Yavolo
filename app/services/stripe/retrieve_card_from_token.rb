# frozen_string_literal: true

require 'stripe'
module Stripe
  # This service is used to retrieve card info form stripe
  class RetrieveCardFromToken < ApplicationService
    attr_reader :status, :errors, :params

    def initialize(params)
      super()
      @params = params
      @status = true
      @errors = []
    end

    def call
      begin
        save_card_details
      rescue StandardError => e
        @status = false
        @errors << e.message
      end
      self
    end

    private

    def save_card_details
      card_details = retrieve_card(stripe_token_id)
      if card_details.present?
        if buyer.buyer_payment_methods.where(stripe_token: stripe_token_id).present?
          buyer.buyer_payment_methods.where(
            stripe_token: stripe_token_id
          ).update(
            last_digits: card_details.card.last4,
            card_holder_name: card_details.card.name,
            card_id: card_details.card.id,
            brand: card_details.card.brand
          )
        else
          buyer.buyer_payment_methods.create(
            stripe_token: stripe_token_id,
            last_digits: card_details.card.last4,
            card_holder_name: card_details.card.name,
            card_id: card_details.card.id,
            brand: card_details.card.brand
          )
        end
      end
    end

    def retrieve_card(stripe_token_id)
      Stripe::Token.retrieve(stripe_token_id) || nil
    end

    def stripe_token_id
      params[:stripe_token_id]
    end

    def buyer
      params[:buyer] || nil
    end
  end
end
