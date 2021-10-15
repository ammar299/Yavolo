class Admin::SellersController < Admin::BaseController
    before_action :set_seller, only: %i[show edit update update_business_representative update_company_detail update_addresses]

    def index
      @q = Seller.ransack(params[:q])
      @sellers = @q.result(distinct: true).page(params[:page]).per(params[:per_page].presence || 15)
    end

    def new
        @seller = Seller.new
        @seller.build_business_representative
        @seller.build_company_detail
    end

    def show
        @remaining_addresses = Address.address_types.keys - @seller.addresses.collect(&:address_type)
        @remaining_addresses.each do |address_type| @seller.addresses.build address_type: address_type end if @remaining_addresses.present?
        unless @seller.seller_api
          @seller_api = @seller.build_seller_api
        else
          @seller_api = @seller.seller_api
        end
    end

    def create
        @seller = Seller.new(seller_params)
        @seller.skip_password_validation = true
        if @seller.save
          redirect_to admin_sellers_path
        else
          render :new
        end
      end

    def edit
    end

    def update_business_representative
      @seller.update(seller_params)
    end

    def update_company_detail
      @seller.update(seller_params)
    end
    
    def update_addresses
      @seller.update(seller_params)
      @address_type = params[:seller][:addresses_attributes]["0"][:address_type]
      @address = @seller.addresses.where(address_type: @address_type).last
    end

    def update_multiple
      if params[:field_to_update].present?
        @seller_ids = params[:seller_ids].split(',') if params[:seller_ids].present?
        if params[:field_to_update] == 'delete'
          Seller.where(id: @seller_ids).destroy_all
        else
          Seller.where(id: @seller_ids).update_all(account_status: params[:field_to_update])
        end
      end
      redirect_to admin_sellers_path
    end

    def update
        if @seller.update(seller_params)
            redirect_to admin_sellers_path
          else
            render :edit
          end
    end

    def update_seller_api
      random_token = SecureRandom.hex(30)
      @seller = Seller.find(params[:seller_id])
      params[:seller_api][:status] = params[:seller_api][:status].to_i
      if @seller.seller_api.present?
        @seller_api = @seller.seller_api
      else
        @seller_api = @seller.build_seller_api
      end
      unless @seller_api.api_token
        @seller_api.api_token = random_token
      end
      @seller_api.name = params[:seller_api][:name]
      @seller_api.status = params[:seller_api][:status]
      @seller_api.save
    end

    def refresh_seller_api
      random_token = SecureRandom.hex(30)
      @seller_api = SellerApi.find(params[:seller_api_id])
      @seller = @seller_api.seller
      @seller_api.api_token = random_token
      @seller_api.save
    end

    private
      def seller_params
        params.require(:seller).permit(:email, :subscription_type,:account_status, :listing_status,
            business_representative_attributes: [:id, :full_legal_name, :email, :job_title, :date_of_birth],
            company_detail_attributes: [:id, :name, :vat_number, :country, :legal_business_name, :companies_house_registration_number, :business_industry, :website_url, :amazon_url, :ebay_url, :doing_business_as],
            addresses_attributes: [:id, :address_line_1, :address_line_2, :city, :county, :country, :postal_code, :phone_number, :address_type]
        )
      end

      def set_seller
        @seller = Seller.includes([ :business_representative, :company_detail, :addresses ]).find(params[:id])
      end
end
