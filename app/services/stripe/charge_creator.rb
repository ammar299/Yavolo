require 'stripe'
module Stripe
  # This service is responsible to charge customers against thier orders
  class ChargeCreator < ApplicationService
    APPLICATION_FEE_AMOUNT = 20
    attr_reader :status, :errors, :params

    def initialize(params)
      super()
      @params = params
      @status = true
      @errors = []
    end

    def call
      begin
        charge_customer_for_order
      rescue StandardError => e
        @status = false
        @errors << e.message
      end
      self
    end

    private

    def charge_customer_for_order
      customer = find_customer(stripe_customer_id)
      create_charge(customer) if customer.present?
    end

    def find_customer(stripe_customer_id)
      Stripe::Customer.retrieve(stripe_customer_id)
    end

    def find_provider_connect_account(stripe_account_id)
      Stripe::Account.retrieve(stripe_account_id)
    end

    def create_charge(customer)
      params = charge_params(customer)
      charge = Stripe::Charge.create(params)
      if charge['paid'] == true
        @order = order.update(order_type: :paid_order)
        order.create_payment_mode(
          payment_through: 'stripe',
          charge_id: charge[:id],
          amount: charge[:amount],
          return_url: charge[:refunds][:url],
          receipt_url: charge[:receipt_url]
        )
      end
    end

    def stripe_token_id
      params[:stripe_token_id] || nil
    end

    def buyer
      params[:buyer] || nil
    end

    def stripe_customer_id
      buyer.stripe_customer.customer_id || nil
    end

    def order
      params[:order] || nil
    end

    def line_items
      order.line_items || []
    end

    def amount
      params[:amount] || 0
    end

    def card_id
      payment_method = buyer.buyer_payment_methods.where(token: stripe_token_id).last
      payment_method.card_id
    end

    def charge_params(customer)
      {
        source: card_id,
        customer: customer.id,
        amount: (amount * 100).to_i,
        description: "#{buyer.email} has paid £#{amount} for Order ID: #{order.id}",
        currency: 'gbp',
        metadata: { order_id: order.id, line_items: line_items },
      }
    end

    # def platform_charges
    #   fee = Setting.last.platform_fee || APPLICATION_FEE_AMOUNT
    #   total_fee = (level.charges * fee / 100) * 100
    #   total_fee.to_i
    # end
  end
end
