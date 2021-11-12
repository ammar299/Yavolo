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

  def actions_to_show(seller)
    if seller.account_status == 'pending' || seller.account_status == 'rejected'
       return ['approve']
    elsif seller.account_status == 'approve'
      return ['suspend']
    elsif seller.account_status == 'suspend'
      return ['activate']
      elsif seller.account_status == 'activate'
        return ['suspend']
    end
  end

  def account_status_to_show(seller)
    if seller.account_status == 'suspend'
      return 'suspended'
    else
      seller.account_status == 'approve' || seller.account_status == 'activate' ? 'active' : seller.account_status
    end
  end

  def multi_actions_to_show
    Seller.account_statuses.select {|status| status != "pending" && status != "rejected" }
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

  def connection_manager_actions_to_show(seller_api)
    if seller_api.status == 'disable'
       return ['enable']
    elsif seller_api.status == 'enable'
      return ['renew','disable']
    end
  end

end
