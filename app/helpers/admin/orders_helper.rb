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

  def order_search_field_query_param_val(q_params)
    [
      q_params[:q][:line_items_product_title_cont],
      q_params[:q][:order_detail_name_cont],
      q_params[:q][:line_items_product_sku_cont],
      q_params[:q][:line_items_product_title_or_order_detail_customer_name_cont_or_line_items_product_sku_cont]
    ].compact.first.to_s unless q_params[:q].blank?
  end

  def order_current_search_field_name
    valid_field_names = %w[line_items_product_title_cont order_detail_name_cont line_items_product_sku_cont line_items_product_title_or_order_detail_customer_name_cont_or_line_items_product_sku_cont]
    valid_field_names.include?(params[:csfname]) ? params[:csfname] : 'line_items_product_title_or_order_detail_customer_name_cont_or_line_items_product_sku_cont'
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
      
end
