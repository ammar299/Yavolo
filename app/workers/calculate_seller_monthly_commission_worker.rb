require 'sidekiq-scheduler'

class CalculateSellerMonthlyCommissionWorker
  include Sidekiq::Worker

  def perform(*args)
    Seller.all.each do |seller|
      create_seller_order_invoice(seller)
    end
  end

  def create_seller_order_invoice(seller)
    @orders = Order.seller_orders(seller).where('orders.created_at >= ? AND orders.created_at <= ?', (DateTime.now-1.month).beginning_of_month, (DateTime.now-1.month).end_of_month)
    @prev_orders = Order.seller_orders(seller).where('orders.created_at >= ? AND orders.created_at <= ?', (DateTime.now-2.month).beginning_of_month, (DateTime.now-2.month).end_of_month)
    if @orders.present?
      @commission = []
      @commission_adjustment = []
      calculate_commission(@orders,seller,"current")
      calculate_commission(@prev_orders,seller,"prev")  if @prev_orders.present?
      @commission = @commission - @commission_adjustment if @commission_adjustment.present?
      seller.billing_listing_stripe.create(invoice_params(@commission.sum))
    end
  end

  def calculate_commission(orders,seller,type)
    orders.each do |order|
      order.line_items.each do |line_item|
        current_commission(line_item,seller) if type == "current"
        prev_commission(line_item,seller) if type == "prev"
      end
    end
  end

  def current_commission(line_item,seller)
    if line_item.product.owner.id == seller.id && line_item.commission_status == "not_refunded"
      @commission << line_item.commission.to_f
    end
  end

  def prev_commission(line_item,seller)
    if line_item.product.owner.id == seller.id && line_item.commission_status == "refunded_later"
      @commission_adjustment << line_item.commission.to_f
    end
  end

  def invoice_params(commission)
    {
      invoice_id: "YAV#{100 + last_count}",
      total: commission,
      description: "Sales commission",
      status: "paid",
      date_generated: DateTime.now,
      due_date: DateTime.now
    }
  end

  def last_count
    count = 0
    last_id = BillingListingStripe.last
    if last_id.present?
      count =  last_id.id
    end
    count
  end

end