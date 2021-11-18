class Sellers::BaseController < ApplicationController
  before_action :authenticate_seller!
  layout 'sellers/seller'
  before_action :set_last_seen_at, if: proc { seller_signed_in? }
  before_action :seller_session_expire, if: proc { seller_signed_in? }
  private

  def set_last_seen_at
    current_seller.update_attribute(:last_seen_at, Time.current)
  end

  def seller_session_expire
    if current_seller.timeout.present?
      seller_time = Time.at(Time.current - current_seller.last_seen_at).utc.strftime("%M").to_i
      seller_timeout = Seller.timeouts[current_seller.timeout] * 60
      if seller_timeout <= seller_time
        sign_out(current_seller)
        redirect_to(:controller => 'sellers/auth/sessions', :action => 'new')
      end
    end
  end
end
