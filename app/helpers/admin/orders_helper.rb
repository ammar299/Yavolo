module Admin::OrdersHelper

  def set_order_sort_by_in_dropdown(params)
    return 'Filter by' unless params.dig(:q, :s).present?
    case params.dig(:q, :s)
    when 'price'
      'Price'
    when 'yavolo'
      'Yavolo'
    else
      'Filter by'
    end
  end

  def admin_order_search_field_query_param_val(q_params)
    [
      q_params[:q][:search_product_a_to_z],
      q_params[:q][:search_product_z_to_a],
      q_params[:q][:order_number_cont],
      q_params[:q][:line_items_product_owner_of_Seller_type_full_name_cont],
      q_params[:q][:order_detail_full_name_cont],
      q_params[:q][:line_items_product_sku_cont],
      q_params[:q][:line_items_product_title_or_order_number_or_line_items_product_owner_of_Seller_type_full_name_or_order_detail_full_name_or_line_items_product_sku_cont]
    ].compact.first.to_s unless q_params[:q].blank?
  end

  def admin_order_current_search_field_name
    valid_field_names = %w[
      search_product_a_to_z
      search_product_z_to_a
      order_number_cont
      line_items_product_owner_of_Seller_type_full_name_cont
      order_detail_full_name_cont
      line_items_product_sku_cont
    ]
    valid_field_names.include?(params[:csfname]) ? params[:csfname] : 'line_items_product_title_or_order_number_or_line_items_product_owner_of_Seller_type_full_name_or_order_detail_full_name_or_line_items_product_sku_cont'
  end

  def order_seller_name(order_line_items)
    seller_names = []
    order_line_items.each do |oli|
      seller_name = oli&.product&.owner&.company_detail&.legal_business_name rescue nil
      seller_names.push(seller_name)
    end
    seller_names.uniq.compact_blank.join(", ")
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

  def order_yavolo_bundle_exist?(order)
    order.line_items.joins('inner join yavolo_bundle_products on line_items.product_id = yavolo_bundle_products.product_id').distinct.count > 0
  end

  def product_sale_month(product)
    count = product.line_items.where("line_items.created_at > ? AND line_items.created_at < ?", Time.now.beginning_of_month, Time.now.end_of_month).pluck(:quantity).inject(:+)
    product.price.to_s.to_d * count.to_s.to_d
  end
end
