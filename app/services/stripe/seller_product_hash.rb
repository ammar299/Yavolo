require 'stripe'
module Stripe
  # This service will return a hash like this
  # [{:seller_id=>1, :seller_connect_account_id=>"acct_1K2Dp72H3hliB8Gb", :seller_paypal_account_id=>"R3V5JZ8AHHP5Q",
  # :total_amount=>0.123123e6, :total_commissioned_amount=>0.1723722e5, :remaining_amount=>0.10588578e6,
  # :products_array=>[#<LineItem id: 50, created_at: "2021-12-26 07:42:52.472677000 +0000",
  # updated_at: "2021-12-26 07:44:11.891130000 +0000", order_id: 60, product_id: 4, price: 0.123123e6,
  # added_on: "2021-12-25T00:09:01+05:00", quantity: 1, transfer_id: "tr_3KArOnFqSiWsjxhX1mHjIA08",
  # transfer_status: "paid", commission: 1, remaining_price: 12, refunded_amount: 0, commission_status: "not_refunded">]}]

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
        amount_hash = commission_and_deducted_amount(line_item[:price], line_item[:quantity].to_i)
        line_item[:commission] = amount_hash[:commission_amount_per_line_item]
        line_item[:remaining_price] = amount_hash[:remaining_amount_per_line_item]
        create_or_update_hash(group_product_with_sellers, product_seller_id, line_item)
        line_item.update(commission: line_item[:commission], remaining_price: line_item[:remaining_price])
      end
      @seller_hash = group_product_with_sellers
    end

    def create_or_update_hash(seller_products_array, seller_id, line_item)
      seller_products = same_seller_products(seller_products_array, seller_id)
      line_item_owner_stripe_connect_account_id = product_owner_stripe_id(line_item)
      line_item_owner_paypal_account_id = product_owner_paypal_id(line_item)
      line_item_price = line_item_price(line_item)
      total_amount = line_item_price * line_item[:quantity].to_i
      amount_hash = commission_and_deducted_amount(line_item_price, line_item[:quantity].to_i)
      if seller_products[:exist]
        update_seller_hash(seller_products[:seller_hash], line_item, total_amount, amount_hash[:commission_amount],
                           amount_hash[:remaining_amount])
      else
        seller_hash = create_seller_hash(seller_id, line_item_owner_stripe_connect_account_id, line_item_owner_paypal_account_id, total_amount,
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

    def create_seller_hash(seller_id, seller_connect_account_id, seller_paypal_account_id, total_amount, commission_amount, remaining_amount, line_item) #line_item is a hash
      { seller_id: seller_id, seller_connect_account_id: seller_connect_account_id, seller_paypal_account_id: seller_paypal_account_id, total_amount: total_amount,
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

    def product_owner_paypal_id(line_item)
      if line_item.product.owner&.paypal_detail&.integration_status.to_s == 'true'
        line_item.product.owner&.paypal_detail&.seller_merchant_id_in_paypal
      else
        raise StandardError.new('seller does not attached paypal account')
      end
    end

    def commission_and_deducted_amount(line_item_price, quantity, commission_amount = COMMISSION)
      commission_amount_per_line_item = calculate_percentage(line_item_price, commission_amount)
      commission_amount = commission_amount_per_line_item * quantity
      remaining_amount_per_line_item = amount_after_commission(commission_amount_per_line_item, line_item_price)
      remaining_amount = remaining_amount_per_line_item * quantity
      { commission_amount_per_line_item: commission_amount_per_line_item, commission_amount: commission_amount,
        remaining_amount_per_line_item: remaining_amount_per_line_item, remaining_amount: remaining_amount }
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