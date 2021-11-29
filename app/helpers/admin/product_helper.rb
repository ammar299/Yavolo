module Admin::ProductHelper

  def product_search_field_params(params)
    val = ""
    if params[:q].present?
      if params[:q][:title_a_z_cont].present?
        val = params[:q][:title_a_z_cont]
      elsif params[:q][:title_z_a_cont].present?
        val = params[:q][:title_z_a_cont]
      elsif params[:q][:price_low_high_cont].present?
        val = params[:q][:price_low_high_cont]
      elsif params[:q][:price_high_low_cont].present?
        val = params[:q][:price_high_low_cont]
      elsif params[:q][:brand_cont].present?
        val = params[:q][:brand_cont]
      elsif params[:q][:sku_cont].present?
        val = params[:q][:sku_cont]
      elsif params[:q][:yan_cont].present?
        val = params[:q][:yan_cont]
      elsif params[:q][:ean_cont].present?
        val = params[:q][:ean_cont]
      elsif params[:q][:title_or_brand_or_sku_or_ean_or_yan_cont].present?
        val = params[:q][:title_or_brand_or_sku_or_ean_or_yan_cont]
      end
    end
    val
  end

  def set_product_filter_by_in_dropdown(params)
    val = 'Filter'
    product_status = Product.statuses.invert.as_json
    if (params[:filter_by] && product_status[params[:filter_by]]).present?
      val = product_status[params[:filter_by]].capitalize
    end
    val
  end

  def set_product_sort_by_in_dropdown(params)
    return 'Filter by' unless params.dig(:q, :s).present?
    case params.dig(:q, :s)
    when 'title asc'
      'Product Title A-Z'
    when 'title desc'
      'Product Title Z-A'
    when 'price asc'
      'Price Low-High'
    when 'price desc'
      'Price High-Low'
    else
      'Filter by'
    end
  end

  def product_sort_param_query_merge_filter(filter)
    q_params = {q: params[:q].present? ? (params.require(:q).merge(s: filter).permit!) : {s: filter} }
    q_params.merge!(filter_type: params[:filter_type]) if params[:filter_type].present?
    q_params.merge!(csfname: params[:csfname]) if params[:csfname].present?
    q_params
  end

  def product_statuses_param_query_merge_filter(filter)
    q_params = {q: params.require(:q).permit! } if params[:q].present?
    q_params.merge!(filter_type: params[:filter_type]) if params[:filter_type].present?
    q_params.merge!(csfname: params[:csfname]) if params[:csfname].present?
    q_params.merge!(filter_by: filter)
    q_params
  end

end
