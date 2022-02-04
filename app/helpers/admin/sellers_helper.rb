module Admin::SellersHelper

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

  def seller_listing_status_to_show(listing_status)
    case listing_status
    when 'in_active'
      'Inactive'
    when 'active'
      'Active'
    else
      ''
    end
  end

  def multi_actions_to_show
    Seller.account_statuses.select {|status| status != "pending" && status != "rejected" }
  end

  def is_eligible?(seller)
    invoice_address = seller.addresses.select do |address| address.address_type == 'invoice_address' end
    return_address = seller.addresses.select do |address| address.address_type == 'return_address' end

    (return_address.present? && invoice_address.present? && seller.bank_detail&.account_verification_status? && seller&.paypal_detail&.integration_status?)
  end

  def show_or_skip_success_steps
    current_seller.skip_success_hub_steps ? 'Show steps' : 'Skip steps'
  end

  def connection_manager_actions_to_show(seller_api)
    if seller_api.status == 'disable'
       return ['enable']
    elsif seller_api.status == 'enable'
      return ['renew','disable']
    end
  end

  def seller_account_statuses_for_dropdown(seller)
    if seller.pending?
      construct_dropdown_options_for_seller_account_statuses(%w(pending approve rejected))
    elsif seller.approve?
      construct_dropdown_options_for_seller_account_statuses( %w(approve suspend))
    elsif seller.rejected?
      construct_dropdown_options_for_seller_account_statuses(%w(approve rejected))
    elsif seller.activate? || seller.suspend?
      construct_dropdown_options_for_seller_account_statuses(%w(activate suspend))
    else
      Seller.account_statuses.map {|k, v| [k.humanize.capitalize, k]}
    end
  end

  def construct_dropdown_options_for_seller_account_statuses(valid_options)
    Seller.account_statuses.select {|k, v| valid_options.include?(k) }.map {|k, v| [k.humanize.capitalize, k]}
  end

  def seller_card_holder_detail(payment_method)
    seller = payment_method.seller
    seller_name = payment_method.card_holder_name
    unless payment_method.card_holder_name.present?
      seller_name = seller.try(:first_name).to_s + " " + seller.try(:last_name).to_s
    end
    seller_name
  end

  def seller_logo_text(seller)
    seller.picture.present? ? 'Update Image' : 'Upload Image'
  end

  def get_seller_api_developer_name(id)
    SellerApi.find_by(id: id)&.developer_name
  end

  def total_sale_price_seller(seller)
    price = 0
    LineItem.user_own_order_line_items(seller).where("transfer_status = ? AND commission_status = ?", 1,0).each do |line_item|
      price += line_item.quantity * line_item.price
    end
    price
  end

  def invoice_total(invoice)
    amount = invoice.total * 0.01
    if invoice.description == "Sales commission"
      amount = invoice.total
    end
    amount = get_price_in_pounds(amount)
  end
end
