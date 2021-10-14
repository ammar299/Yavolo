class Admin::SellersController < Admin::BaseController
    before_action :set_seller, only: %i[show edit update]

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

    private
    def seller_params
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
