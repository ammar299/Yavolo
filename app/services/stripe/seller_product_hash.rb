require 'stripe'
module Stripe
  # This service will return a hash like this
  # [{seller_id: 1, seller_connect_account_id: acct_123123, total_amount: 123, total_commissioned_amount: 1, remaining_amount: 23, products_array: [{line_item: line_item}] }]
  class SellerProductHash < ApplicationService
    attr_reader :status, :errors, :params, :seller_hash

    def initialize(params)
      super()
      @params = params
      @status = true
      @errors = []
      @seller_hash = nil
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

    def separate_cart_item_wrt_seller
      group_product_with_sellers = []
      order_line_items.each do |line_item|
        product_seller_id = product_owner_id(line_item)
        line_item[:price] = line_item_price(line_item)
        create_or_update_hash(group_product_with_sellers, product_seller_id, line_item)
      end
      @seller_hash = group_product_with_sellers
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

    def same_seller_products(seller_products_array, seller_id)
      seller_hash = seller_products_array.select { |h| h[:seller_id] == seller_id }
      { exist: seller_hash.length.positive?, seller_hash: seller_hash.first }
    end

    def product_owner_stripe_id(line_item)
      if line_item.product.owner&.bank_detail&.account_verification_status.to_s == 'true'
        line_item.product.owner&.bank_detail&.customer_stripe_account_id
      else
        raise StandardError.new('seller does not attached bank account')
      end
    end

    def commission_and_deducted_amount(line_item_price, commission_amount = COMMISSION)
      commission_amount = calculate_percentage(line_item_price, commission_amount)
      remaining_amount = amount_after_commission(commission_amount, line_item_price)
      { commission_amount: commission_amount, remaining_amount: remaining_amount }
    end

    def order
      params[:order] || nil
    end

    def order_line_items
      order.line_items || []
    end

    def product_owner_id(line_item)
      line_item.product.owner.id
    end

    def line_item_price(line_item)
      line_item.product.price
    end

    def calculate_percentage(value, percent)
      (value * percent) / 100
    end

    def amount_after_commission(commission_amount, total_amount)
      total_amount - commission_amount
    end

    def amount_to_lower_unit(amount)
      (amount * 100).to_i
    end
  end
end