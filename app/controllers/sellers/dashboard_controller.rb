class Sellers::DashboardController < Sellers::BaseController
    before_action :check_if_seller_profile_completed
    def index; end

    def check_if_seller_profile_completed
        @seller = authenticate_seller!
        if @seller.company_detail.nil?
          redirect_to sellers_auth_sign_up_steps_path
        elsif @seller.addresses.where(address_type: 'business_address').first.nil?
          redirect_to sellers_auth_sign_up_steps_path
        elsif @seller.company_detail.nil?
          redirect_to sellers_auth_sign_up_steps_path
        elsif @seller.addresses.where(address_type: 'business_representative_address').first.nil?
          redirect_to sellers_auth_sign_up_steps_path
        end
      end
end