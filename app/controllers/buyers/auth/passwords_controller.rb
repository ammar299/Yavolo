# frozen_string_literal: true

class Buyers::Auth::PasswordsController < Devise::PasswordsController
  layout 'buyers/buyer'

  protected

  def after_sending_reset_password_instructions_path_for(resource_name)
    forgot_password_path
  end
end
