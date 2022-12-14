module ApplicationHelper
  def get_errors(form,field)
    column = form.object.errors.where(field).last
    has_error = column.present?
    msg = column.full_message if has_error
    [has_error,msg]
  end

  def set_active_tab(tab_item, tab_param)
    tab_item==tab_param ? 'active' : ''
  end

  def create_url(controller_to_hit, form_to_update, seller_id, address_id = nil)
    if controller_to_hit == 'sellers/profiles'
      if form_to_update.include?('address')
        edit_sellers_profile_path(id: seller_id, form_to_update: form_to_update, address_id: address_id)
      else
        if form_to_update == 'remove_seller_logo'
          remove_logo_image_sellers_profile_path
        else
          edit_sellers_profile_path(id: seller_id, form_to_update: form_to_update)
        end
      end
    else
      if form_to_update.include?('address')
        edit_admin_seller_path(id: seller_id, form_to_update: form_to_update, address_id: address_id)
      else
        if form_to_update == 'remove_seller_logo'
          remove_logo_image_admin_seller_path
        else
          edit_admin_seller_path(id: seller_id, form_to_update: form_to_update)
        end
      end
    end
  end

  def return_value(value)
    value.present? ? value : ''
  end

  def address_type_filter(address, filter)
    if address.address_type == filter
      address
    end
  end

  def address_format(address)
    address.try(:address_line_1).to_s + "\n" + address.try(:address_line_2).to_s + "\n" + address.try(:county).to_s + "\n" + address.try(:city).to_s + "\n" + address.try(:postal_code).to_s + "\n" + address.try(:country).to_s
  end

  def seller_api_url(from_controller, seller)
    if from_controller == 'sellers/profiles'
      new_sellers_connection_manager_path(id: seller.id)
    else
      new_seller_api_admin_seller_path
    end
  end

  def section_to_show(from_controller)
    from_controller == 'sellers/profiles' ? false : true
  end

  def search_field_query_param_val(q_params)
    [
      q_params[:q][:title_cont],
      q_params[:q][:brand_cont],
      q_params[:q][:sku_cont],
      q_params[:q][:yan_cont],
      q_params[:q][:ean_cont],
      q_params[:q][:title_or_brand_or_sku_or_yan_or_ean_cont]
    ].compact.first.to_s unless q_params[:q].blank?
  end

  def search_field_query_param_val_yavolo(q_params)
    [
      q_params[:q][:yavolo_bundle_products_title_cont],
      q_params[:q][:yavolo_bundle_products_brand_cont],
      q_params[:q][:yavolo_bundle_products_sku_cont],
      q_params[:q][:yavolo_bundle_products_yan_cont],
      q_params[:q][:yavolo_bundle_products_ean_cont],
      q_params[:q][:yavolo_bundle_products_title_or_yavolo_bundle_products_brand_or_yavolo_bundle_products_sku_or_yavolo_bundle_products_yan_or_yavolo_bundle_products_ean_cont]
    ].compact.first.to_s unless q_params[:q].blank?
  end

  def search_field__delivery_option_param(q_params)
    [
      q_params[:q][:name_cont],
      q_params[:q][:name_or_ships_name_cont]
    ].compact.first.to_s unless q_params[:q].blank?
  end

  def connection_manager_actions_to_show(seller_api)
    if seller_api.status == 'disable'
       return ['enable']
    elsif seller_api.status == 'enable'
      return ['renew','disable']
    end
  end

  def admin_seller_route?(from_controller)
    from_controller == "admin/sellers" ? true : false
  end

  def create_update_seller_api_confirmation_path(form_controller, seller, seller_api, action)
    if form_controller == 'sellers/profiles' || form_controller == "sellers/connection_managers"
      confirm_update_sellers_connection_manager_path(seller_api_id: seller_api.id, param_to_update: action)
    else
      confirm_update_seller_api_admin_seller_path(id: seller.id, seller_api_id: seller_api.id, param_to_update: action)
    end
  end

  def seller_account_setting_top_bar_buttons(active_tab)
    if active_tab == 'about'
      return true
    else
      return false
    end
  end

  def delivery_form_class(params)
    klass = ''
    if params[:from].present? && params[:from] == 'create_product'
      klass = 'box-border yo-white-card'
    end
    klass
  end

  def current_search_field_name_yavolo
    valid_field_names = ['products_title_cont','products_brand_cont','products_sku_cont','products_yan_cont','products_ean_cont',
'products_title_or_products_brand_or_products_sku_or_products_yan_or_products_ean_cont']
    valid_field_names.include?(params[:csfname]) ? params[:csfname] : 'products_title_or_products_brand_or_products_sku_or_products_yan_or_products_ean_cont'
  end

  def current_search_field_name
    valid_field_names = ['title_cont','brand_cont','sku_cont','yan_cont','ean_cont',
'title_or_brand_or_sku_or_yan_or_ean_cont']
    valid_field_names.include?(params[:csfname]) ? params[:csfname] : 'title_or_brand_or_sku_or_yan_or_ean_cont'
  end

  def current_search_field_delivery_name
    valid_field_names = ['name_cont', 'name_or_ships_name_cont']
    valid_field_names.include?(params[:csfname]) ? params[:csfname] : 'name_or_ships_name_cont'
  end


  def set_filter_active(f_type)
    'active' if set_filter_type_in_dropdown(params)==f_type
  end

  def set_filter_check_none(f_type)
    'd-none' unless set_filter_type_in_dropdown(params)==f_type
  end

  def get_price_in_pounds(amount)
    amount.present? ? number_to_currency(amount, unit: "??", precision: 2) : 0
  end

  def strip_currency_from_price(amount)
    amount.split('??').join('').delete(',')
  end

  def format_to_percentage(number)
    number.present? ? number_to_percentage(number,precision:8, scale: 2, strip_insignificant_zeros: true) : number_to_percentage(0,precision:0)
  end

  def set_filter_type_in_dropdown(params)
    val = "Search All"
    if params[:filter_type].present?
      val = params[:filter_type]
    end
    val
  end

  def date_format_US(date)
    date.strftime('%m/%d/%Y')
  end

  def date_format_UK(date)
    date.strftime('%d/%m/%Y')
  end

  def connection_expiry_time(time)
    time.strftime('%I:%M%p')
  end

  def get_time_from_date_time(datetime)
    datetime.strftime('%I:%M:%S %p') # Returns in this format "03:17:31 PM"
  end

  def countries_list
    COUNTRIES_HASH_LIST.map { |obj| [obj[:name]] }
  end

  def default_country
    "United Kingdom"
  end

  def return_to_returns_address(address_type)
    if address_type == 'return_address'
      return 'returns_address'
    elsif address_type == 'business_representative_address'
      return 'representative_address'
    else
      return address_type
    end
  end

  # def address_type_change_case(address_type)
  #   if address_type == 'return_address'
  #     return 'RETURNS ADDRESS'
  #   elsif address_type == 'business_representative_address'
  #     return 'REPRESENTATIVE ADDRESS'
  #   elsif address_type == 'business_address'
  #     return 'BUSINESS ADDRESS'
  #   elsif address_type == 'invoice_address'
  #     return 'INVOICE ADDRESS'
  #   else
  #     return address_type
  #   end
  # end

  def seller_basic_info_modal_titles(address_type)
    case address_type
    when 'business_representative'
      return 'representative_details'
    when 'company_detail'
      return 'company_details'
    else
      return address_type
    end
  end

  def multisteps_signup?
    params[:multistep] == "true"
  end

  def action_performed_value(action_name)
    action_hash = ACTION_NAME_WITH_ACTION_STATUS.select { |h| h[:action_name] == action_name }.last
    action_hash.present? ? action_hash[:action_performed] : action_name
  end

  def titleize(str)
    str.to_s.titleize
  end

  def authorise_developer_by_seller_or_admin
    ((current_seller.present? && current_seller.eligible_to_create_api) ||
        (current_admin.present? && admin_seller_route?(params[:controller])))
  end

  def product_seller_name(product_id)
    Product.find_by(id: product_id).owner.try(:company_detail)&.name&.titleize
  end

  def admin_route?(from_controller)
    from_controller.include?("admin")
  end

  # converts numbers to human readable form e.g 98765432.98 to 98,765,432.98
  def human_readable_count(value)
    number_with_delimiter(value, delimiter: ",", separator: ".")
  end

  def form_headings(admin_heading,seller_heading)
    admin_route?(params[:controller]) ? admin_heading : seller_heading
  end

  def seller_modal_heading(heading_text)
    case heading_text
    when "business_representative"
      value = 'Representative Details'
    when "company_detail"
      value = 'Company Details'
    when "business_representative_address"
      value = 'Representative Address'
    when "return_address"
      value = 'Returns Address'
    else
      value = heading_text.humanize
    end
    value
  end

  def active_class_when_exact(expected_route)
    request.path == expected_route ? 'active' : nil
  end

  def active_class_sidebar(expected_routes)
    is_route_active_left_side_bar(expected_routes) ? 'active' : nil
  end

  def d_none_class_sidebar(expected_routes)
    is_route_active_left_side_bar(expected_routes) ? nil : 'd-none'
  end

  def is_route_active_left_side_bar(expected_routes)
    if expected_routes.is_a?(Array)
      expected_routes.any? {|r| request.path.include?(r) }
    else
      request.path.include?(expected_routes)
    end
  end

end
