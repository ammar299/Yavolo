class Sellers::Auth::PasswordsController < Devise::PasswordsController

  def after_resetting_password_path_for(resource)
    Devise.sign_in_after_reset_password ? after_sign_in_path_for(resource) : new_session_path(resource_name)
  end

  def after_sign_in_path_for(resource)
    super(resource)
    sellers_seller_authenticated_root_path # or whatever path you want here
  end
end
