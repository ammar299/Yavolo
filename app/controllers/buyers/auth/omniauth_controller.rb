class Buyers::Auth::OmniauthController < Devise::OmniauthCallbacksController
  # google callback
  def google_oauth2
    @buyer = Buyer.create_from_provider_data(request.env['omniauth.auth'])
    if @buyer.persisted?
      flash[:notice] = 'Signed In Successfully!'
      sign_in_and_redirect @buyer, :event => :authentication #this will throw if @buyer is not activated
    else
      session['devise.google_oauth2_data'] = request.env['omniauth.auth']
      redirect_to new_buyer_registration_url
    end
  end

  # facebook callback
  def facebook
    @buyer = Buyer.create_from_provider_data(request.env['omniauth.auth'])
    if @buyer.persisted?
      flash[:notice] = 'Signed In Successfully!'
      sign_in_and_redirect @buyer, :event => :authentication #this will throw if @buyer is not activated
    else
      session['devise.facebook_data'] = request.env['omniauth.auth']
      redirect_to new_buyer_registration_url
    end
  end

  def failure
    flash[:error] = 'There was a problem signing you in. Please register or try signing in later.'
    redirect_to new_buyer_registration_url
  end
end
