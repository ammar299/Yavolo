require 'paypal-payouts-sdk'
include PaypalPayoutsSdk::Payouts

module Paypal
  class PayoutCreator < ApplicationService
    attr_reader :status, :errors, :params, :client, :paypal_payout_response

    def initialize(params)
      @params = params
      @status = true
      @errors = []
      @paypal_response = nil
    end

    def call
      begin
        paypal_client_creator = Paypal::PaypalClientCreator.call({})
        @client = paypal_client_creator.client if paypal_client_creator.status
        @paypal_payout_response = create_payouts(debug) if paypal_client_creator.status
      rescue StandardError => e
        @status = false
        @errors << e.message
      end
      self
    end

    private

    def debug
      @debug = params[:debug] ? true : false
    end

    def seller_hash
      params[:seller_hash] || []
    end

    # [{:seller_id=>1, :seller_connect_account_id=>"acct_1K2Dp72H3hliB8Gb", :seller_paypal_account_id=>"R3V5JZ8AHHP5Q",
    # :total_amount=>0.123123e6, :total_commissioned_amount=>0.1723722e5, :remaining_amount=>0.10588578e6,
    # :products_array=>[#<LineItem id: 50, created_at: "2021-12-26 07:42:52.472677000 +0000",
    # updated_at: "2021-12-26 07:44:11.891130000 +0000", order_id: 60, product_id: 4, price: 0.123123e6,
    # added_on: "2021-12-25T00:09:01+05:00", quantity: 1, transfer_id: "tr_3KArOnFqSiWsjxhX1mHjIA08",
    # transfer_status: "paid">]}]

    def create_items_payload
      items = []
      # line_item value will be refactored when payout becomes massPay
      total_amount = 0
      seller_hash.each do |seller_details|
        total_amount += seller_details[:remaining_amount].to_f
        items.push({
                     note: "Here is your payout of #{seller_details[:remaining_amount]}",
                     amount: {
                       currency: 'GBP',
                       value: seller_details[:remaining_amount]
                     },
                     recipient_type: 'PAYPAL_ID',
                     receiver: seller_details[:seller_paypal_account_id],
                     sender_item_id: "yavolo_batch_payout_product_id_#{SecureRandom.base64(6)}"
                   })
      end
      raise StandardError, 'Sorry! cannot transfer more than 15000 per API' if total_amount > 15_000

      items
    end

    def build_create_payload(include_validation_failure = false)
      sender_batch_id = "Yavolo_order_payout_#{SecureRandom.base64(6)}"
      amount = include_validation_failure ? '1.0.0' : '1.00'
      items_arr = create_items_payload
      {
        sender_batch_header: {
          email_message: 'SDK payouts test txn',
          note: 'Enjoy your Payout!!',
          sender_batch_id: sender_batch_id,
          email_subject: 'This is a test transaction from SDK'
        },
        items: items_arr
      }
    end

    # Creates a payout batch with 5 payout items
    # Calls the create batch api (POST - /v1/payments/payouts)
    # A maximum of 15000 payout items are supported in a single batch request
    def create_payouts(debug = false)
      body = build_create_payload()
      request = PayoutsPostRequest.new()
      request.request_body(body)

      # begin
      @client.execute(request)
    end
  end
end