module Sellers::OrdersHelper

  def order_current_search_field_name
    valid_field_names = %w[
      line_items_product_title_cont
      idfilter_cont
      order_detail_name_cont
      shipping_address_postal_code_or_billing_address_postal_code_cont
      line_items_product_sku_cont
      line_items_product_yan_cont
      line_items_product_ean_cont
    ]
    valid_field_names.include?(params[:csfname]) ? params[:csfname] : 'line_items_product_title_or_order_detail_name_or_shipping_address_postal_code_or_billing_address_postal_code_or_line_items_product_sku_or_line_items_product_yan_or_line_items_product_ean_or_idfilter_cont'
  end

  def order_search_field_query_param_val(q_params)
    [
      q_params[:q][:line_items_product_title_cont],
      q_params[:q][:idfilter_cont],
      q_params[:q][:order_detail_name_cont],
      q_params[:q][:shipping_address_postal_code_or_billing_address_postal_code_cont],
      q_params[:q][:line_items_product_sku_cont],
      q_params[:q][:line_items_product_yan_cont],
      q_params[:q][:line_items_product_ean_cont],
      q_params[:q][:line_items_product_title_or_order_detail_name_or_shipping_address_postal_code_or_billing_address_postal_code_or_line_items_product_sku_or_line_items_product_yan_or_line_items_product_ean_or_idfilter_cont]
    ].compact.first.to_s unless q_params[:q].blank?
  end
end
