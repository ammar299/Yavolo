require 'stripe'
module Stripe
  # This service is responsible to transfer amount to sellers against their orders
  class TransferAmount < ApplicationService
    attr_reader :status, :errors, :params

    def initialize(params)
      super()
      @params = params
      @status = true
      @errors = []
    end

    def call
      begin
        transfer_amount_to_sellers(seller_hash)
      rescue StandardError => e
        @status = false
        @errors << e.message
      end
      self
    end

    private

    def transfer_amount_to_sellers(seller_grouped_products_array)
      seller_grouped_products_array.each do |seller_hash|
        seller_stripe_account_id = find_provider_connect_account(seller_hash[:seller_connect_account_id])
        if seller_stripe_account_id.present?
          transfer_amount_stripe(seller_hash)
        end
      end
    end

    def transfer_amount_stripe(seller_hash)
      seller_id = seller_hash[:seller_id]
      seller_stripe_account_id = seller_hash[:seller_connect_account_id]
      amount_to_transfer_to_seller = seller_hash[:remaining_amount]
      products_array = seller_hash[:products_array]
      payload = transfer_amount_payload(seller_stripe_account_id, amount_to_transfer_to_seller, charge_id)
      transfer = Stripe::Transfer.create(payload)
      Orders::UpdateLineItemsToPaid.call(
        { seller_id: seller_id, transfer_id: transfer.id, products_array: products_array }
      )
    end

    def transfer_amount_payload(seller_stripe_account_id, amount_to_transfer_to_seller, charge_id)
      {
        amount: (amount_to_transfer_to_seller * 100).to_i,
        currency: 'gbp',
        destination: seller_stripe_account_id,
        source_transaction: charge_id
      }
    end

    def find_provider_connect_account(stripe_account_id)
      Stripe::Account.retrieve(stripe_account_id)
    end

    def seller_hash
      params[:seller_hash] || []
    end

    def charge_id
      params[:charge_id] || nil
    end
  end
end