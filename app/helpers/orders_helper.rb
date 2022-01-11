module OrdersHelper

  def get_vat_numbers(line_items)
    vat_number_collection = []
    line_items.each do |line_item|
      vat_number = line_item&.product&.owner&.company_detail&.vat_number rescue nil
      vat_number_collection.push(vat_number)
    end
    vat_number_collection.compact.uniq.join(", ")
  end

  def order_number_format(code)
    code.slice! "YAVO"
    "##{code}"
  end

  def get_full_name(object)
    "#{object&.first_name}"+" "+"#{object&.last_name}"
  end

  def refund_reason_options
    Refund.refund_reasons.map { |text, value| [text.split('_').map(&:capitalize).join(' '), text] }
  end

  def formatted_order_date(order)
    order.strftime("%H:%M, %m/%d/%Y")
  end

  def confirm_refund_modal_body(params)
    if params.present?
      refund_reason(params) + message_to_buyer(params) + message_to_seller(params) + refund_total(params)
    else
      refund_placeholder_text
    end
  end

  def refund_reason(params)
    refund_reason_param = params[:refund][:refund_reason]
    "<p class='font-14px'><strong>Reason for refund</strong><br>#{refund_reason_param.present? ? refund_reason_param.titleize : ""}</p>".html_safe
  end

  def message_to_buyer(params)
    buyer_message_param = params[:refund_messages]["0"][:buyer_message]
    "<p class='font-14px'><strong>Message to buyer</strong><br>#{buyer_message_param.present? ? buyer_message_param : "There is no message included"}</p>".html_safe
  end

  def message_to_seller(params)
    message_to_seller_collection = ''
    params[:refund_messages].each.with_index do |value, index|
      next if params[:refund_messages][value[0]][:buyer_message].present? || index == 0
      seller_id_param = params[:refund_messages][value[0]][:seller_id]
      seller_message_param = params[:refund_messages][value[0]][:seller_message]
      seller_name = get_seller_name(seller_id_param)
      message_to_seller_collection += "<p class='font-14px'><strong>Message to seller " + seller_name + "</strong><br>#{seller_message_param.present? ? seller_message_param : 'There is no message included'}</p>"
    end
    message_to_seller_collection.html_safe
  end

  def refund_total(params)
    refund_total_param = params[:refund][:total_refund]
    "<p class='font-14px'><strong>Refund total</strong><br>#{get_price_in_pounds(refund_total_param.present? ? refund_total_param : 0)}</p>".html_safe
  end

  def get_seller_name(seller_id)
    seller = Seller.find(seller_id) rescue nil
    "#{seller.first_name.present? ? seller.first_name : ""} #{seller.last_name.present? ? seller.last_name : ""}" if seller.present?
  end

  def refund_placeholder_text
    "<p class='font-14px'><strong>Reason for refund</strong><br>No reason selected</p>"
    "<p class='font-14px'><strong>Message to buyer</strong><br>There is no message is included</p>"
    "<p class='font-14px'><strong>Message to seller</strong><br>There is no message is included</p>"
    "<p class='font-14px'><strong>Refund total</strong><br>£0.00</p>"
  end

  def current_logged_in_user
    current_admin.present? ? current_admin : current_seller
  end

  def current_user_namespace
    controller.class.module_parent == Sellers ? "sellers" : "admin"
  end

end
