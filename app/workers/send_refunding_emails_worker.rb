class SendRefundingEmailsWorker
  include Sidekiq::Worker

  def perform(refund_messages)
    refund_messages_params = JSON.parse(refund_messages.gsub('=>', ':'))
    refund_messages_params.each.with_index do |refund_message, index|
      order = get_order(refund_messages_params[refund_message[0]]["order_id"])
      buyer_id_param = refund_messages_params[refund_message[0]]["buyer_id"]
      buyer_message_param = refund_messages_params[refund_message[0]]["buyer_message"]
      buyer_email(buyer_id_param, buyer_message_param, order.order_number) if index == 0 && buyer_message_param.present?
      seller_message_param = refund_messages_params[refund_message[0]]["seller_message"]
      next if seller_message_param.blank?
      seller_id_param = refund_messages_params[refund_message[0]]["seller_id"]
      seller_email(seller_id_param, seller_message_param, order.order_number)
    end
  end

  def buyer_email(buyer_id, buyer_message, order_number)
    order_buyer = Buyer.find_by(id: buyer_id) rescue nil
    RefundMailer.with(to: order_buyer.email, buyer_message: buyer_message, order_number: order_number).send_buyer_email.deliver_now
  end

  def seller_email(seller_id, seller_message, order_number)
    product_seller = Seller.find_by(id: seller_id) rescue nil
    RefundMailer.with(to: product_seller.email, seller_message: seller_message, order_number: order_number).send_seller_email.deliver_now
  end

  def get_order(order_id)
    Order.find_by(id: order_id) rescue nil
  end

end