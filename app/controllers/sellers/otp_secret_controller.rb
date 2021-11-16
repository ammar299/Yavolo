class Sellers::OtpSecretController < Sellers::BaseController
  def new
    @otp_secret = ROTP::Base32.random
    totp = ROTP::TOTP.new(
      @otp_secret, issuer: 'YourAppName'
    )
    @qr_code = RQRCode::QRCode
      .new(totp.provisioning_uri(current_seller.email))
      .as_png(resize_exactly_to: 200)
      .to_data_url
  end

  def create
    @otp_secret = params[:otp_secret]
    totp = ROTP::TOTP.new(
      @otp_secret, issuer: 'YourAppName'
    )

    last_otp_at = totp.verify(
      params[:otp_attempt], drift_behind: 15
    )

    if last_otp_at
      current_seller.update(
        otp_secret: @otp_secret, last_otp_at: last_otp_at
      )
      redirect_to(
        sellers_seller_authenticated_root_path,
        notice: 'Successfully configured OTP protection for your account'
      )
    else
      flash.now[:alert] = 'The code you provided was invalid!'
      @qr_code = RQRCode::QRCode
        .new(totp.provisioning_uri(current_seller.email))
        .as_png(resize_exactly_to: 200)
        .to_data_url
      render :new
    end
  end
end