require 'stripe'
module Stripe
  # This service is responsible to charge customers against thier orders
  class ChargeCreator < ApplicationService
    APPLICATION_FEE_AMOUNT = 20
    attr_reader :status, :errors, :params, :charge

    def initialize(params)
      super()
      @params = params
      @status = true
      @errors = []
      @charge = nil
    end

    def call
      begin
        separate_cart_item_wrt_seller
      rescue StandardError => e
        @status = false
        @errors << e.message
      end
      self
    end

    private

    def separate_charge_for_each_seller_grouped_product(seller_grouped_products_array)
      seller_grouped_products_array.each do |seller_hash|
        customer = find_customer(stripe_customer_id)
        if customer.present?
          charge_through_stripe(customer, seller_hash[:seller_connect_account_id],
                                seller_hash[:total_commissioned_amount], seller_hash[:total_amount],
                                seller_hash[:products_array])
        end
      end
    end

    def separate_cart_item_wrt_seller
      group_product_with_sellers = []
      order_line_items.each do |line_item|
        product_seller_id = product_owner_id(line_item)
        create_or_update_hash(group_product_with_sellers, product_seller_id, line_item)
      end
      separate_charge_for_each_seller_grouped_product(group_product_with_sellers)
    end

    def product_owner_id(line_item)
      line_item.product.owner.id
    end

    def product_owner_stripe_id(line_item)
      if line_item.product.owner&.bank_detail&.account_verification_status == true ||
          line_item.product.owner&.bank_detail&.account_verification_status == 'true'
        line_item.product.owner&.bank_detail&.customer_stripe_account_id
      else
        raise StandardError.new('seller does not attached bank account')
      end
    end

    # [{seller_id: 1, seller_connect_account_id: acct_123123, total_amount: 123, total_commissioned_amount: 1, remaining_amount: 23, products_array: [{line_item: line_item}] }]
    def same_seller_products(seller_products_array, seller_id)
      seller_hash = seller_products_array.select { |h| h[:seller_id] == seller_id }
      { exist: seller_hash.length.positive?, seller_hash: seller_hash.first }
    end

    def update_seller_hash(same_seller_products_array, line_item, total_amount, commission_amount, remaining_amount)
      same_seller_products_array[:total_amount] += total_amount
      same_seller_products_array[:total_commissioned_amount] += commission_amount
      same_seller_products_array[:remaining_amount] += remaining_amount
      same_seller_products_array[:products_array].push(line_item)
    end

    def create_seller_hash(seller_id, seller_connect_account_id, total_amount, commission_amount, remaining_amount, line_item) #line_item is a hash
      { seller_id: seller_id, seller_connect_account_id: seller_connect_account_id, total_amount: total_amount,
        total_commissioned_amount: commission_amount, remaining_amount: remaining_amount, products_array: [line_item] }
    end

    def create_or_update_hash(seller_products_array, seller_id, line_item)
      seller_products = same_seller_products(seller_products_array, seller_id)
      line_item_owner_stripe_connect_account_id = product_owner_stripe_id(line_item)
      line_item_price = line_item_price(line_item)
      amount_hash = commission_and_deducted_amount(line_item_price)
      if seller_products[:exist]
        update_seller_hash(seller_products[:seller_hash], line_item, line_item_price, amount_hash[:commission_amount],
                           amount_hash[:remaining_amount])
      else
        seller_hash = create_seller_hash(seller_id, line_item_owner_stripe_connect_account_id, line_item_price,
                                         amount_hash[:commission_amount], amount_hash[:remaining_amount], line_item)
        seller_products_array.push(seller_hash)
      end
    end

    def line_item_price(line_item)
      line_item.product.price
    end

    def find_customer(stripe_customer_id)
      Stripe::Customer.retrieve(stripe_customer_id)
    end

    def find_provider_connect_account(stripe_account_id)
      Stripe::Account.retrieve(stripe_account_id)
    end

    def charge_through_stripe(customer, destination_account_id, platform_fee, charge_amount, line_item)
      params = charge_params(customer, destination_account_id, platform_fee, charge_amount, line_item)
      @charge = Stripe::Charge.create(params)
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

    def order_line_items
      order.line_items || []
    end

    def amount
      params[:amount] || 0
    end

    def card_id
      payment_method = buyer.buyer_payment_methods.where(token: stripe_token_id).last
      payment_method.card_id
    end

    def charge_params(customer, destination_account_id, platform_fee, charge_amount, line_items)
      {
        source: card_id,
        customer: customer.id,
        amount: amount_to_lower_unit(charge_amount),
        description: "#{buyer.email} has paid £#{amount} for Order ID: #{order.id}",
        currency: 'gbp',
        application_fee_amount: amount_to_lower_unit(platform_fee),
        transfer_data: {
          destination: destination_account_id
        },
        metadata: { order_id: order.id, order_line_items: order_line_items.to_json.to_s, 
                    line_items: line_items.to_json.to_s }
      }
    end

    def amount_to_lower_unit(amount)
      (amount * 100).to_i
    end

    def commission_and_deducted_amount(line_item_price, commission_amount = COMMISSION)
      commission_amount = calculate_percentage(line_item_price, commission_amount)
      remaining_amount = amount_after_commission(commission_amount, line_item_price)
      { commission_amount: commission_amount, remaining_amount: remaining_amount }
    end

    def calculate_percentage(value, percent)
      (value * percent) / 100
    end

    def amount_after_commission(commission_amount, total_amount)
      total_amount - commission_amount
    end
  end
end
