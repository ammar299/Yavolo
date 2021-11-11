class Sellers::DashboardController < Sellers::BaseController
    before_action :check_if_seller_profile_completed
    
    def index
      @yavolo_products_percent = Product.yavolo_percent(current_seller)
    end

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
          return
        end
      else
        unless @seller.company_detail.present? || @seller.business_representative.present? || @seller.addresses.where(address_type: 'business_address').first.present? || @seller.addresses.where(address_type: 'business_representative_address').first.present?
          redirect_to new_sellers_profile_path(id: @seller.id)
        end
      end
    end

end
