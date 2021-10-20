# frozen_string_literal: true

class Sellers::Auth::RegistrationsController < Devise::RegistrationsController
  def after_sign_up_path_for(resource)
    super(resource)
    sellers_auth_sign_up_steps_path # or whatever path you want here
  end
end
