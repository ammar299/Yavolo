module ApplicationHelper
  def get_errors(form,field)
    column = form.object.errors.where(field).last
    has_error = column.present?
    msg = column.full_message if has_error
    [has_error,msg]
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
    elsif controller_to_hit == 'admin/sellers'
      if form_to_update.include?('address')
        edit_admin_seller_path(id: seller_id, form_to_update: form_to_update, address_id: address_id)
      else
        if form_to_update == 'remove_seller_logo'
          remove_logo_image_admin_seller_path
        else
          edit_admin_seller_path(id: seller_id, form_to_update: form_to_update)
        end
      end
      edit_admin_seller_path(id: seller_id, form_to_update: form_to_update)
    end
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
end
