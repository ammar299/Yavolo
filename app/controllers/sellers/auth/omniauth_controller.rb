class Sellers::Auth::OmniauthController < Devise::OmniauthCallbacksController

  # google callback
  def google_oauth2
    @seller = Seller.create_from_provider_data(request.env['omniauth.auth'])
    if @seller.persisted?
      sign_in_and_redirect @seller, :event => :authentication #this will throw if @seller is not activated
    else
      session["devise.google_oauth2_data"] = request.env["omniauth.auth"]
      redirect_to new_seller_registration_url
    end
  end

  # facebook callback
  def facebook
    @seller = Seller.create_from_provider_data(request.env['omniauth.auth'])
    if @seller.persisted?
      sign_in_and_redirect @seller, :event => :authentication #this will throw if @seller is not activated
    else
      session["devise.facebook_data"] = request.env["omniauth.auth"]
      redirect_to new_seller_registration_url
    end
  end

  def failure
    flash[:error] = 'There was a problem signing you in. Please register or try signing in later.'
    redirect_to new_seller_registration_url
  end
end
