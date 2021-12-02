class Sellers::Auth::PasswordsController < Devise::PasswordsController

  def after_resetting_password_path_for(resource)
    Devise.sign_in_after_reset_password ? new_session_path(resource_name) : new_session_path(resource_name)
  end

  def after_sign_in_path_for(resource)
    super(resource)
    sellers_seller_authenticated_root_path # or whatever path you want here
  end

  def update
    seller_password = Seller.find params[:seller_id]
    if seller_password.valid_password?(params[:seller][:password]) == false
      self.resource = resource_class.reset_password_by_token(resource_params)
      yield resource if block_given?

      if resource.errors.empty?
        resource.unlock_access! if unlockable?(resource)
        if Devise.sign_in_after_reset_password
          flash_message = resource.active_for_authentication? ? :updated : :updated_not_active
          set_flash_message!(:notice, flash_message)
          resource.after_database_authentication
          sign_in(resource_name, resource)
        else
          set_flash_message!(:notice, :updated_not_active)
        end
        respond_with resource, location: after_resetting_password_path_for(resource)
      else
        set_minimum_password_length
        respond_with resource
      end
    else
      flash[:notice] = 'Previous password can not save as current password'
      redirect_back fallback_location: root_path
    end
  end

end
