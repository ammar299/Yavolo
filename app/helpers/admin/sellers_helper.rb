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

  def return_value(value)
    value.present? ? value : ''
  end

  def address_format(address)
    address.try(:address_line_1).to_s + "\n" + address.try(:address_line_2).to_s + "\n" + address.try(:county).to_s + "\n" + address.try(:city).to_s + "\n" + address.try(:postal_code).to_s + "\n" + address.try(:country).to_s
  end

  def address_type_filter(address, filter)
    if address.address_type == filter
      address
    end
  end

end