module Admin::SellersHelper

  def search_field_params(params)
    val = ""
    if params[:q].present?
      if params[:q][:first_name_or_last_name_cont].present?
        val = params[:q][:first_name_or_last_name_cont]
      elsif params[:q][:email_cont].present?
        val = params[:q][:email_cont]
      elsif params[:q][:first_name_or_last_name_or_email_cont].present?
        val = params[:q][:first_name_or_last_name_or_email_cont]
      end
    end
    val
  end

  def set_filter_type_in_dropdown(params)
    val = "Search All"
    if params[:filter_type].present?
      val = params[:filter_type]
    end
    val
  end

end
