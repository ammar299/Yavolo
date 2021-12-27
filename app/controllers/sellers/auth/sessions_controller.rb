# frozen_string_literal: true

class Sellers::Auth::SessionsController < Devise::SessionsController

  def create
    @seller = Seller.find_by_email params[:seller][:email]
    if @seller.present? && @seller.rejected? 
      message = "Your account has been rejected"
      redirect_to new_seller_session_path, notice: message
    elsif @seller.present? && @seller.two_factor_auth == true
      if @seller.valid_password?(params[:seller][:password])
        session[:emai] = params[:seller][:email]
        redirect_to two_auth_new_path and return
      else
        super
      end
    else
      super
    end
  end

  # DELETE /resource/sign_out
  def destroy
    current_seller.last_seen_at = nil
    current_seller.save
    super
  end

  def two_auth_new
    @current_seller = Seller.find_by_email session[:emai]
    @otp_secret = ROTP::Base32.random
    totp = ROTP::TOTP.new(
      @otp_secret, issuer: 'Yavolo',
      :interval => 30
    )
    @qr_code = RQRCode::QRCode
      .new(totp.provisioning_uri(@current_seller.email))
      .as_png(resize_exactly_to: 200)
      .to_data_url
  end

  def two_auth_create
    current_seller = Seller.find_by_email session[:emai]
    @otp_secret = params[:otp_secret]
    totp = ROTP::TOTP.new(
      @otp_secret, issuer: 'Yavolo',
      :interval => 30
    )

    last_otp_at = totp.verify(
      params[:otp_attempt], drift_behind: 15
    )
    if last_otp_at
      current_seller.update(
        otp_secret: @otp_secret, last_otp_at: last_otp_at
      )
      current_seller.after_database_authentication
      bypass_sign_in current_seller, scope: :seller
      session[:email] = nil
      redirect_to(
        sellers_seller_authenticated_root_path,
        notice: 'Successfully logged in'
      )
    else
      # @qr_code = RQRCode::QRCode
      #   .new(totp.provisioning_uri(current_seller.email))
      #   .as_png(resize_exactly_to: 200)
      #   .to_data_url
      redirect_to two_auth_new_path, flash: { notice: "The code you provided was invalid!" }
    end
  end
  
  def after_sign_in_path_for(resource)
    super(resource)
    sellers_seller_authenticated_root_path # or whatever path you want here
  end

  def after_sign_out_path_for(resource_or_scope)
    new_seller_session_path
  end


end
