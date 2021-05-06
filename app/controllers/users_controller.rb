class UsersController < ApplicationController
    before_action :authenticate_user!
    before_action :set_user
    
    def edit; end

    def update
        @user.update(user_params)
        redirect_to profile_path
    end

    def edit_password; end
    
    def update_password
        if @user.update_password_with_password(password_update_params)
            bypass_sign_in(@user)
            redirect_to profile_path, flash: { notice: "Successfully updated password" }
        else
            render 'edit_password'
        end
    end

    def show; end

    private

    def set_user
        @user = if params[:id]
            User.find(params[:id])
        else
            current_user
        end
    end

    def user_params
        params.require(:user).permit(:first_name, :surname, :avatar)
    end

    def password_update_params
        params.require(:user).permit(:current_password, :password, :password_confirmation)
    end
end