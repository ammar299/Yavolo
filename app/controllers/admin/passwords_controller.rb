# frozen_string_literal: true

class Admin::PasswordsController < Devise::PasswordsController
  # GET /resource/password/new
  # def new
  #   super
  # end

  def create
  
    if Admin.find_by_email(params[:admin][:email]).present?
      self.resource = resource_class.send_reset_password_instructions(resource_params)
      yield resource if block_given?
      if successfully_sent?(resource)
        respond_with({}, location: new_admin_password_path(reset_password: true))
      else
        respond_with(resource)
      end
    else
      redirect_to new_admin_password_path, flash: { notice: "Email does not exists" }
    end
  end

  # GET /resource/password/edit?reset_password_token=abcdef
  # def edit
  #   super
  # end

  # PUT /resource/password
  # def update
  #   super
  # end

  # protected

  # def after_resetting_password_path_for(resource)
  #   super(resource)
  # end

  # The path used after sending reset password instructions
  # def after_sending_reset_password_instructions_path_for(resource_name)
  #   super(resource_name)
  # end
end
