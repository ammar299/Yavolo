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

  def actions_to_show(seller)
    if seller.account_status == 'pending' || seller.account_status == 'rejected'
       return ['approve']
    elsif seller.account_status == 'approve'
      return ['activate','suspend']
    elsif seller.account_status == 'suspend'
      return ['activate']
      elsif seller.account_status == 'activate'
        return ['suspend']
    end
  end

  def multi_actions_to_show
    Seller.account_statuses.select {|status| status != "pending" && status != "rejected" }
  end

  def seller_api_status(seller_api, status_type)
    if seller_api.status.present?
      if seller_api.status == status_type
        true
      else
        false
      end
    elsif status_type == 'enable'
      true
    end
  end

  def is_eligible?(seller)
    invoice_address = seller.addresses.select do |address| address.address_type == 'invoice_address' end
    return_address = seller.addresses.select do |address| address.address_type == 'return_address' end
    
    if seller.picture.present? && invoice_address.present? && return_address.present?
      return true
    else
      return false
    end
  end

end