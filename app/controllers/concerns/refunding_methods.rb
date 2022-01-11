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
      @create_refund = refunding_procedures(api_response, "stripe")
    when "paypal"
      # paypal refund service
      api_response = Paypal::PaypalRefundCreator.call(params)
      @create_refund = refunding_procedures(api_response, "paypal")
    else
      @errors = 'No payment method attached to the order or we cannot process refunds for this payment method.'
    end
  end

  def refunding_procedures(api_response, payment_processor)
    @errors = api_response.errors.join("<br/>").html_safe if api_response.errors.present?
    if payment_processor == "stripe"
      @create_refund = create_successful_refund(api_response, payment_processor) if api_response.reversal_hash.present? || api_response.refund_hash.present?
    elsif payment_processor == 'paypal'
      @create_refund = create_successful_refund(api_response, payment_processor) if JSON.parse(api_response.to_json)["refund_hash"].present?
    end
  end

  def create_successful_refund(api_response, payment_processor)
    @refund = current_order.refunds.build(order_refund_params)
    if @refund.save
      refunding_attributes = refunding_related_information(api_response, payment_processor)
      create_reversal_modes(api_response, payment_processor)
      create_refund_details(refunding_attributes)
      create_refund_modes(refunding_attributes)
      SendRefundingEmailsWorker.perform_async(params[:refund_messages])
      { success: true, errors: "" }
    else
      { success: false, errors: @refund.errors.full_messages.join('') }
    end
  end

  def create_refund_details(refunding_attributes)
    filtered_attributes = refunding_attributes.map { |refunding_attribute| refunding_attribute.except("buyer_id", "response_refund_id", "charge_id", "refund_through", "status") }
    @refund.refund_details.create(filtered_attributes)
  end

  def create_reversal_modes(api_response, payment_processor)
    @refund.reversal_modes.create(api_response.reversal_hash) if payment_processor == "stripe"
    # need to create paypal reversal modes here by checking payment_processor but its on hold due to client.
  end

  def create_refund_modes(refunding_attributes)
    @refund.refund_modes.create(refunding_attributes)
  end

  def refunding_related_information(api_response, payment_processor)
    active_record_array = []
    if payment_processor == 'stripe'
      active_record_array = api_response.refund_hash
    elsif payment_processor == 'paypal'
      active_record_array = JSON.parse(api_response.to_json)["refund_hash"]
    end
    active_record_array
  end

  def show
    @order_detail = current_order.order_detail
    @order_shipping_address = current_order.shipping_address
    @order_billing_address = current_order.billing_address
  end

  private

  def order_refund_params
    params.require(:refund).permit(:refund_reason, :total_paid, :total_refund)
  end

  def current_order
    @order = Order.find_by(id: params[:id]) rescue nil
  end
end