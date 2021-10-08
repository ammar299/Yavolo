class Admin::SellersController < ApplicationController
    before_action :set_seller, only: %i[show edit update]

    def index
        @sellers = Seller.all
    end

    def new
        @seller = Seller.new
        @seller.build_business_representative
        @seller.addresses.build
        @seller.build_company_detail
    end

    def show; end

    def create
        @seller = Seller.new(seller_params)
        @seller.skip_password_validation = true
        byebug
        if @seller.save
          redirect_to admin_sellers_path
        else
          render :new
        end
      end

    def edit
    end

    def update_business_representative
        @seller = Seller.find(params[:seller_id])
    end

    def update
        byebug
    end

    private
    def seller_params
        byebug
        params.require(:seller).permit(:email, :subscription_type,
            business_representative_attributes: [:id, :full_legal_name, :email, :job_title, :date_of_birth, :contact_number],
            company_detail_attributes: [:id, :name, :vat_number, :country, :legal_business_name, :companies_house_registration_number, :business_industry, :business_phone, :website_url, :amazon_url, :ebay_url, :doing_business_as],
            addresses_attributes: [:id, :address_line_1, :address_line_2, :city, :county, :country, :postal_code, :phone_number, :address_type]
        )
      end

      def set_seller
        @seller = Seller.includes([ :business_representative, :company_detail, :addresses ]).find(params[:id])
      end
end
