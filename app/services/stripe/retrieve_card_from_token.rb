# frozen_string_literal: true

require 'stripe'
module Stripe
  # This service is used to retrieve card info form stripe
  class RetrieveCardFromToken < ApplicationService
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
        @response = retrieve_card(stripe_token_id)
      rescue StandardError => e
        @status = false
        @errors << e.message
      end
      self
    end

    private

    def save_card_details
      retrieve_card(stripe_token_id)
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
