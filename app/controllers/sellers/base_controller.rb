class Sellers::BaseController < ApplicationController
  before_action :authenticate_seller!
  layout 'sellers/seller'
  before_action :seller_session_expire, if: proc { seller_signed_in? }
  after_action :set_last_seen_at, if: proc { seller_signed_in? }
  private

  def set_last_seen_at
    current_seller.update_attribute(:last_seen_at, Time.current)
  end

  def seller_session_expire
    if current_seller.rejected? || current_seller.is_locked?
      message = "Your account has been #{current_seller.rejected? ? "rejected" : "locked"}"
      sign_out(current_seller)
      redirect_to new_seller_session_path, notice: message
    elsif current_seller.timeout.present? &&  current_seller.last_seen_at.present?
      seller_time = Time.at(Time.current - current_seller.last_seen_at).utc.strftime("%M").to_i
      seller_timeout = Seller.timeouts[current_seller.timeout] * 60
      if seller_timeout <= seller_time
        current_seller.last_seen_at = nil
        current_seller.save
        sign_out(current_seller)
        redirect_to(:controller => 'sellers/auth/sessions', :action => 'new')
      end
    end
  end

  def validate_seller_dashboard!
    return_address = current_seller.addresses.select do |address| address.address_type == 'return_address' end
    invoice_address = current_seller.addresses.select do |address| address.address_type == 'invoice_address' end
    return if return_address.present? && invoice_address.present? && current_seller.bank_detail.present? && current_seller&.paypal_detail&.integration_status? && current_seller.products.count > 0

    redirect_to sellers_seller_authenticated_root_path, flash: { notice: 'Please complete your dashboard required steps!' }
  end
end
