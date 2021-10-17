class Admin::SellersController < Admin::BaseController
    before_action :set_seller, only: %i[show edit update update_business_representative update_company_detail update_addresses update_seller_logo remove_logo_image confirm_update_seller update_seller]

    def index
      @q = Seller.ransack(params[:q])
      @sellers = @q.result(distinct: true).order('created_at').page(params[:page]).per(params[:per_page].presence || 15)
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

    def update_seller_logo
      @seller.update(seller_params)
    end
      
    def remove_logo_image
      @seller.picture.destroy if @seller.picture.present?
    end
    
    def update_addresses
      @seller.update(seller_params)
      @address_type = params[:seller][:addresses_attributes]["0"][:address_type]
      @address = @seller.addresses.where(address_type: @address_type).last
    end

    def update_seller
      if params[:field_to_update].present?
        if params[:field_to_update] == 'delete'
          @seller.destroy
        else
          @previous = @seller.account_status
          @seller.update(account_status: params[:field_to_update])
        end
      end
    end

    def confirm_multi_update
    end

    def update_multiple
      if params[:field_to_update].present? && params[:ids].present?
        @seller_ids = params[:ids].split(',')
        if params[:field_to_update] == 'delete'
          @sellers = Seller.find(@seller_ids)
          Seller.where(id: @seller_ids).destroy_all
        else
          Seller.where(id: @seller_ids).update_all(account_status: params[:field_to_update])
          @sellers = Seller.find(@seller_ids)
        end
      end
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

    def export_sellers
      @all_sellers = Seller.all
      respond_to do |format|
        format.html
        format.csv { send_data @all_sellers.to_csv, filename: "#{Date.today}-sellers.csv" }
      end
      if @all_sellers.size > 100
        csv = @all_sellers.to_csv
        AdminMailer.export_sellers_email(csv).deliver!
      end
    end

    def import_sellers
      csv_import = CsvImport.new(params.require(:csv_import_sellers).permit(:file))
      csv_import.importer_id = current_admin.id
      csv_import.importer_type = 'Admin'
      if csv_import.valid?
        csv_import.save
        csv_import.update({status: :uploaded})
        ImportSellersWorker.perform_async(csv_import.id)
        render json: { message: 'Your file is uploaded and you will be notified with import status.' }, status: :ok
      else
        render json: { errors: csv_import.errors.where(:file).last.message }, status: :unprocessable_entity
      end
    end

    private
      def seller_params
        params.require(:seller).permit(:email, :subscription_type,:account_status, :listing_status,
            business_representative_attributes: [:id, :full_legal_name, :email, :job_title, :date_of_birth],
            company_detail_attributes: [:id, :name, :vat_number, :country, :legal_business_name, :companies_house_registration_number, :business_industry, :website_url, :amazon_url, :ebay_url, :doing_business_as],
            addresses_attributes: [:id, :address_line_1, :address_line_2, :city, :county, :country, :postal_code, :phone_number, :address_type],
            picture_attributes: ["name", "@original_filename", "@content_type", "@headers", "_destroy", "id"],
          )
      end

      def set_seller
        @seller = Seller.includes([ :business_representative, :company_detail, :addresses ]).find(params[:id])
      end
end
