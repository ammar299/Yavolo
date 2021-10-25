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
      sellers_profile_update_seller_api_path(seller.id)
    else
      admin_seller_update_seller_api_path(seller.id)
    end
  end

  def seller_api_refresh_url(from_controller, seller, seller_api)
    if from_controller == 'sellers/profiles'
      sellers_profile_refresh_seller_api_path(seller, seller_api)
    else
      confirm_refresh_api_admin_seller_path(seller, seller_api: seller_api)
    end
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

  def section_to_show(from_controller)
    from_controller == 'sellers/profiles' ? false : true
  end
end
