class Sellers::DashboardController < Sellers::BaseController
    before_action :check_if_seller_profile_completed
    
    def index; end

    def check_if_seller_profile_completed
        @seller = authenticate_seller!
        if @seller.multistep_sign_up
          if @seller.company_detail.nil?
            redirect_to sellers_auth_sign_up_steps_path
          elsif @seller.addresses.where(address_type: 'business_address').first.nil?
            redirect_to sellers_auth_sign_up_steps_path
          elsif @seller.business_representative.nil?
            redirect_to sellers_auth_sign_up_steps_path
          elsif @seller.addresses.where(address_type: 'business_representative_address').first.nil?
            redirect_to sellers_auth_sign_up_steps_path
          elsif @seller.bank_detail.nil?
            redirect_to sellers_auth_sign_up_steps_path
          else
            redirect_to sellers_auth_sign_up_steps_path
          end
        else
          unless @seller.company_detail.present? || @seller.business_representative.present? || @seller.addresses.where(address_type: 'business_address').first.present? || @seller.addresses.where(address_type: 'business_representative_address').first.present?
            redirect_to new_sellers_profile_path(seller_id: @seller.id)
          end
        end
      end
end