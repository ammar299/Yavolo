# frozen_string_literal: true

class Sellers::Auth::RegistrationsController < Devise::RegistrationsController
  before_action :configure_sign_up_params, only: [:create]

  def after_sign_up_path_for(resource)
    super(resource)
    if params[:multistep].present? && params[:multistep] == "true"
      sellers_auth_sign_up_steps_path # or whatever path you want here
    else
      new_sellers_profile_path(seller_id: resource)
    end
  end

  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name, :last_name, :email, :password, :multistep_sign_up, :account_status])
  end
end
