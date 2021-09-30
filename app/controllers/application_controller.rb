class ApplicationController < ActionController::Base
  # before_action :authenticate_user!
  # before_action :configure_permitted_parameters, if: :devise_controller?

  # protected

  # def after_sign_in_path_for(resource)
  #   if resource.is_a?(User)
  #       if resource.seller?
  #           seller_dashboard_path
  #       else
  #           buyer_dashboard_path
  #       end
  #   else
  #       super
  #   end
  # end

  # def configure_permitted_parameters
  #   devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name, :surname, :role, :email_confirmation, :terms_and_conditions, :receive_best_deals])
  #   devise_parameter_sanitizer.permit(:account_update, keys: [:first_name, :surname])
  # end
end