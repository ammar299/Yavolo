module Admin::OrdersHelper

  def set_order_sort_by_in_dropdown(params)
    return 'Filter by' unless params.dig(:q, :s).present?
    case params.dig(:q, :s)
    when 'price'
      'Price'
    else
      'Filter by'
    end
  end

  def admin_order_search_field_query_param_val(q_params)
    [
      q_params[:q][:line_items_product_title_cont],
      q_params[:q][:order_number_cont],
      q_params[:q][:line_items_product_owner_of_Seller_type_first_name_or_line_items_product_owner_of_Seller_type_last_name_cont],
      q_params[:q][:order_detail_name_cont],
      q_params[:q][:line_items_product_sku_cont],
      q_params[:q][:line_items_product_title_or_order_number_or_line_items_product_owner_of_Seller_type_first_name_or_line_items_product_owner_of_Seller_type_last_name_or_order_detail_name_or_line_items_product_sku_cont]
    ].compact.first.to_s unless q_params[:q].blank?
  end

  def admin_order_current_search_field_name
    valid_field_names = %w[
      line_items_product_title_cont
      order_number_cont
      line_items_product_owner_of_Seller_type_first_name_or_line_items_product_owner_of_Seller_type_last_name_cont
      order_detail_name_cont
      line_items_product_sku_cont
    ]
    valid_field_names.include?(params[:csfname]) ? params[:csfname] : 'line_items_product_title_or_order_number_or_line_items_product_owner_of_Seller_type_first_name_or_line_items_product_owner_of_Seller_type_last_name_or_order_detail_name_or_line_items_product_sku_cont'
  end

  def order_seller_name(order_line_items)
    order_line_items.first.product.owner.full_name rescue ""
  end
  
  def order_status(order)
    if order.order_type == "paid_order"
      return "Paid order"
    elsif order.order_type == "abundent_checkout"
      return "Abundent checkout"
    else
      return nil
    end
  end

  def refund_reason_options
    Refund.refund_reasons.map {|text, value| [text.split('_').map(&:capitalize).join(' '), text]}
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
    buyer_message_param = params[:refund][:refund_messages_attributes]["0"][:buyer_message]
    "<p class='font-14px'><strong>Message to buyer</strong><br>#{buyer_message_param.present? ? buyer_message_param : "There is no message included"}</p>".html_safe
  end

  def message_to_seller(params)
    message_to_seller_collection = ''
    params[:refund][:refund_messages_attributes].each do |index|
      next if params[:refund][:refund_messages_attributes][index[0]][:buyer_message].present?
      seller_id_param = params[:refund][:refund_messages_attributes][index[0]][:seller_id]
      seller_message_param = params[:refund][:refund_messages_attributes][index[0]][:seller_message]
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
end
