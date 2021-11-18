class Admin::SellersController < Admin::BaseController
  before_action :set_seller, only: %i[show edit update update_business_representative update_company_detail update_addresses update_seller_logo remove_logo_image confirm_update_seller update_seller new_seller_api create_seller_api confirm_update_seller_api change_seller_api_eligibility holiday_mode change_lock_status  confirm_reset_password_token reset_password_token update_subscription_by_admin]

  def index
    @q = Seller.ransack(params[:q])
    @sellers = @q.result(distinct: true).order(created_at: :desc).page(params[:page]).per(params[:per_page].presence || 15)
  end

  def new
    @seller = Seller.new
    @seller.build_business_representative
    @seller.build_company_detail
  end

  def show
    @delivery_options =  @seller.delivery_options
    @remaining_addresses = Address.address_types.keys - @seller.addresses.collect(&:address_type)
    if @remaining_addresses.present?
      @remaining_addresses.each do |address_type|
        @seller.addresses.build address_type: address_type
      end
    end
    @seller_apis = @seller.seller_apis
    @seller_id = params[:id]
  end

  def create
    @seller = Seller.new(seller_params)
    @seller.skip_password_validation = true
    if @seller.save
      AdminMailer.with(to: @seller.email.to_s.downcase).send_account_creation_email.deliver_now
      redirect_to admin_sellers_path, flash: { notice: 'Seller has been saved' }
    else
      render :new
    end
  end

  def create
    @seller = Seller.new(seller_params)
    @seller.skip_password_validation = true
    if @seller.save
      AdminMailer.with(to: @seller.email.to_s.downcase).send_account_creation_email.deliver_now
      redirect_to admin_sellers_path, flash: { notice: "Seller has been saved" }
    else
      render :new
    end
  end

  def edit; end

  def update_business_representative
    if seller_params[:listing_status] == 'in_active'
      # change this seller's products status to inactive
      @seller.products.where(status: :active).update(status: :inactive)
    else
      @seller.products.where(status: :inactive).update(status: :active)
    end
    @seller.update(seller_params)
    flash.now[:notice] = 'Business Representative updated successfully!'
  end

  def update_company_detail
    @seller.update(seller_params)
    flash.now[:notice] = 'Company Detail updated successfully!'
  end

  def update_seller_logo
    @image_valid = true
    file_path = params[:seller][:picture_attributes][:name].tempfile.path
    if Yavolo::ImageProcessing.image_dimensions_valid?(file_path:file_path, width: 500, height: 500)
      @seller.update(seller_params)
      flash.now[:notice] = 'Seller Logo updated successfully!'
    else
      @image_valid = false
      flash.now[:notice] = 'Image must be a .jpg, .gif or .png file smaller
            than 10MB and at least 500px by 500px.'
    end
  end

  def remove_logo_image
    @picture_present = @seller.picture.present?
    @seller.picture.destroy if @picture_present
    flash.now[:notice] = 'Seller Logo removed successfully!' if @picture_present
  end

  def update_addresses
    @seller.update(seller_params)
    @address_type = params[:seller][:addresses_attributes]['0'][:address_type]
    @address = @seller.addresses.where(address_type: @address_type).last
    flash.now[:notice] = "#{@address_type.humanize} updated successfully!"
  end

  def update_seller
    if params[:field_to_update].present?
      if params[:field_to_update] == 'delete'
        @seller.destroy
        flash.now[:notice] = 'Seller deleted successfully!'
      else
        @previous = @seller.account_status
        @seller.update(account_status: params[:field_to_update])
        flash.now[:notice] = 'Seller updated successfully!'
      end
    end
  end

  def confirm_multi_update; end

  def update_multiple
    if params[:field_to_update].present? && params[:ids].present?
      @seller_ids = params[:ids].split(',')
      if params[:field_to_update] == 'delete'
        @sellers = Seller.find(@seller_ids)
        Seller.where(id: @seller_ids).destroy_all
        flash.now[:notice] = 'Sellers deleted successfully!'
      else
        Seller.where(id: @seller_ids).update_all(account_status: params[:field_to_update])
        @sellers = Seller.find(@seller_ids)
        flash.now[:notice] = 'Sellers updated successfully!'
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
  def update
    if @seller.update(seller_params)
      redirect_to admin_sellers_path
    else
      render :edit
    end
  end

  def new_seller_api
    @seller_api = @seller.seller_apis.build
  end

  def create_seller_api
    @seller_api = SellerApi.new(seller_api_params)
    @seller_api.seller_id = @seller.id
    @seller_api.api_token = SecureRandom.hex(30)
    @seller_api.developer_id = SecureRandom.hex(7)
    @seller_api.expiry_date = Date.today + 6.month
    @seller_api.status = 'enable'
    @seller_api.save
    flash.now[:notice] = 'Seller API created successfully!'
  end

  def update_seller_api
    @seller = Seller.find(params[:seller_id])
    @seller_api = @seller.seller_apis.where(id: params[:seller_api_id]).last
    if params[:field_to_update].present? && @seller_api.present?
      if params[:field_to_update] == 'renew'
        @seller_api.api_token = SecureRandom.hex(30)
        @seller_api.developer_id = SecureRandom.hex(7)
        @seller_api.expiry_date = Date.today + 6.month
        @seller_api.save
        flash.now[:notice] = 'Seller API renewed successfully!'
      else
        @seller_api.update(status: params[:field_to_update])
        flash.now[:notice] = 'Seller API updated successfully!'
      end
    end
  end

  def change_seller_api_eligibility
    bool = @seller.eligible_to_create_api == true ? false : true
    @seller.update(eligible_to_create_api: bool)
    text = bool == false ? 'Disabled Seller API creation successfully!' : 'Enabled Seller API creation successfully!'
    flash.now[:notice] = text.to_s
  end

  def change_lock_status
    bool = @seller.is_locked == true ? false : true
    @seller.update(is_locked: bool)
    text = bool == false ? 'Unlocked seller successfully!' : 'Locked seller successfully!'
    flash.now[:notice] = text.to_s
  end

  def holiday_mode
    if holiday_mode_params[:holiday_mode] == 0 || holiday_mode_params[:holiday_mode] == '0'
      # change this seller's products status to inactive
      @seller.products.where(status: :active).update(status: :inactive)
    else
      @seller.products.where(status: :inactive).update(status: :active)
    end
    @seller.update(holiday_mode_params)
    text = @seller.holiday_mode == true ? 'Enabled holiday mode successfully' : 'Disabled holiday mode successfully'
    flash.now[:notice] = text.to_s
  end
  
  def export_sellers
    selected_sellers = get_sellers()
    all_sellers = []
    selected_sellers.each do |seller|
      seller = Seller.find(seller)
      all_sellers << seller
    end
    
    if all_sellers.size > 0
      respond_to do |format|
        format.html
        format.csv { send_data Seller.new.to_csv(all_sellers), filename: "#{Date.today}-export-sellers.csv" }
      end
      
      csv = Seller.new.to_csv(all_sellers)
      ExportSellerCsvViaEmailWorker.perform_async(current_admin.email, csv)
    end
  end

  def get_sellers
    sellers = []
    seller_ids = params[:sellers].split(",")
    seller_ids.each do |seller|
      sellers << seller.to_i
    end
    return sellers
  end

  def reset_password_token
    raw, hashed = Devise.token_generator.generate(Seller, :reset_password_token)
    @seller.reset_password_token = hashed
    @seller.reset_password_sent_at = Time.now.utc
    if @seller.save
      Devise::Mailer.reset_password_instructions(@seller, raw).deliver_now
      flash.now[:notice] = 'Reset password sent to your email successfully!'
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

  def search
    @q = Seller.ransack(params[:q])
    @sellers = @q.result(distinct: true).order('created_at').page(params[:page]).per(params[:per_page].presence || 10)
    render json: {
      sellers: @sellers.as_json(only: [:id], methods: :full_name),
      total_count: @sellers.total_count
    }, status: :ok
  end

  def update_subscription_by_admin
    begin
      subscription = Admins::Sellers::SubscriptionUpdaterService.call({status: params[:subsciption_status], seller: @seller })
      case subscription.status
      when "canceled"
        flash.now[:notice] = "Subscription status canceled for seller: #{current_seller.email}"
      when "12_month"
        flash.now[:notice] = "Subscription status changed to 12 month"
      when "24_month"
        flash.now[:notice] = "Subscription status changed to 24 month"
      when "lifetime"
        flash.now[:notice] = "Subscription status changed to lifetime"
      else
        flash.now[:notice] = "Got into some errors please try again later!!  Errors: #{subscription.errors[0]}"
      end
    rescue
      flash.now[:notice] = "Please refresh page first !!"
    end
  end

  def remove_seller_card
    payment_method = SellerPaymentMethod.find(params[:id].to_i) if params[:id].to_i.present?
    @seller = payment_method.seller
    if payment_method.default_status == true
      flash.now[:notice] =  'You cannot remove this card because it is selected as default card'
    else
      payment_method.detach_payment_method(params)
      flash.now[:notice] =  'Card removed successfully!!'
    end
  end

    private
  def seller_params
    params.require(:seller).permit(:first_name, :last_name, :email, :subscription_type,:account_status, :listing_status,
                                   business_representative_attributes: [:id, :full_legal_name, :email, :job_title, :date_of_birth],
                                   company_detail_attributes: [:id, :name, :vat_number, :country, :legal_business_name, :companies_house_registration_number, :business_industry, :website_url, :amazon_url, :ebay_url, :doing_business_as],
                                   addresses_attributes: [:id, :address_line_1, :address_line_2, :city, :county, :country, :postal_code, :phone_number, :address_type],
                                   picture_attributes: ['name', '@original_filename', '@content_type', '@headers', '_destroy', 'id'],
      )
  end

  def seller_api_params
    params.require(:seller_api).permit(:developer_name, :app_name)
  end

  def holiday_mode_params
    params.require(:seller).permit(:holiday_mode)
  end

  def set_seller
    @seller = Seller.includes([ :business_representative, :company_detail, :addresses ]).find(params[:id])
  end
end
