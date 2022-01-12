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
      refund_api_response = Stripe::RefundCreator.call(params)
      parsed_api_response = parsing_refunding_response(refund_api_response)
      @create_refund = refunding_procedures(parsed_api_response, "stripe")
    when "paypal"
      # paypal refund service
      refund_api_response = Paypal::PaypalRefundCreator.call(params)
      parsed_api_response = parsing_refunding_response(refund_api_response)
      @create_refund = refunding_procedures(parsed_api_response, "paypal")
    else
      @errors = 'No payment method attached to the order or we cannot process refunds for this payment method.'
    end
  end

  def refunding_procedures(parsed_api_response, payment_processor)
    @errors = parsed_api_response[:errors].join("").html_safe if parsed_api_response[:errors].present?
    @create_refund = create_successful_refund(parsed_api_response, payment_processor)
  end

  def create_successful_refund(refunding_attributes, payment_processor)
    if refunding_attributes[:reversal_hash].present? || refunding_attributes[:refund_hash].present?
      refund_params = create_refunds(refunding_attributes)
      @refund = current_order.refunds.build(refund_params)
      if @refund.save
        create_refund_details(refunding_attributes[:refund_hash])
        create_reversal_modes(refunding_attributes[:reversal_hash]) if payment_processor == "stripe"
        create_refund_modes(refunding_attributes[:refund_hash])
        SendRefundingEmailsWorker.perform_async(refunding_attributes[:refund_messages])
        @notices = refunding_attributes[:notices].join("").html_safe if refunding_attributes[:notices].present?
        { success: true, errors: "", notices: @notices }
      else
        { success: false, errors: @refund.errors.full_messages.join(''), notices: "" }
      end
    end
  end

  def create_refunds(refunding_attributes)
    {
      "refund_reason" => refunding_attributes[:refund_reason],
      "total_paid" => refunding_attributes[:total_paid],
      "total_refund" => refunding_attributes[:total_refund]
    }
  end

  def create_refund_details(refunding_attributes)
    refund_details_attributes = refunding_attributes.map { |refunding_attribute| refunding_attribute.except("buyer_id", "response_refund_id", "charge_id", "refund_through", "status") }
    @refund.refund_details.create(refund_details_attributes)
  end

  def create_reversal_modes(reversal_hash)
    @refund.reversal_modes.create(reversal_hash)
    # need to create paypal reversal modes here by checking payment_processor but its on hold due to client.
  end

  def create_refund_modes(refund_hash)
    @refund.refund_modes.create(refund_hash)
  end

  def parsing_refunding_response(api_response)
    refund_response = JSON.parse(api_response.to_json)
    refund_messages = refund_response["params"]["refund_messages"]
    refund_reason   = refund_response["params"]["refund"]["refund_reason"]
    total_paid      = refund_response["params"]["refund"]["total_paid"].to_f
    refund_hash     = refund_response["refund_hash"]
    total_refund    = refund_hash.sum { |key| key["amount_refund"].to_f }
    reversal_hash   = refund_response["reversal_hash"]
    errors          = refund_response["errors"]
    notices         = refund_response["notices"]
    {
      refund_messages: refund_messages,
      refund_reason: refund_reason.to_sym,
      total_paid: total_paid,
      total_refund: total_refund,
      refund_hash: refund_hash,
      reversal_hash: reversal_hash,
      errors: errors,
      notices: notices
    }
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