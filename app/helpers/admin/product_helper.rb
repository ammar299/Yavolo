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

end
