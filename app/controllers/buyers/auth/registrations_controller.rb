# frozen_string_literal: true

class Buyers::Auth::RegistrationsController < Devise::RegistrationsController
  layout 'buyers/buyer'

  before_action :configure_sign_up_params, only: [:create]


  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: %i[first_name surname email email_confirmation password
                                                         terms_and_conditions receive_deals_via_email])
  end
end
