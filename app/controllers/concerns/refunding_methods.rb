module RefundingMethods
  extend ActiveSupport::Concern

  def new_refund
    @commission = COMMISSION
    @refund = current_order.refunds.build
  end

  def get_refund
    @commission = COMMISSION
  end

  def create_refund
    case current_order&.buyer_payment_method&.payment_method_type
    when "stripe"
      # stripe refund service
      api_response = Stripe::RefundCreator.call(params)
      if api_response.errors.present?
        @errors = api_response.errors.join("<br/>").html_safe
      else
        @create_refund = create_successful_refund(api_response)
      end
    when "paypal"
      # paypal refund service
      PayPal::PaypalOrderPaymentRefund.call(params)
    else
      @errors = 'No payment method attached to the order or we cannot process refunds for this payment method.'
    end
  end

  def create_successful_refund(api_response)
    @refund = current_order.refunds.build(order_refund_params)
    if @refund.save
      @refund.reversal_modes.create(api_response.reversal_hash)
      @refund.refund_modes.create(api_response.refund_hash)
      SendRefundingEmailsWorker.perform_async(params[:refund_messages])
      { success: true, errors: "" }
    else
      { success: false, errors: @refund.errors.full_messages.join('') }
    end
  end

  def show
    @order_detail = current_order.order_detail
    @order_shipping_address = current_order.shipping_address
    @order_billing_address = current_order.billing_address
  end

  private

  def order_refund_params
    params.require(:refund).permit(:refund_reason, :total_paid, :total_refund,
                                   refund_details_attributes: [:id, :order_id, :product_id, :amount_paid, :amount_refund, :line_item_id])

  end

  def current_order
    @order = Order.find(params[:id])
  end
end