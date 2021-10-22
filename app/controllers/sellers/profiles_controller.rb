class Sellers::ProfilesController < Sellers::BaseController
  layout 'application', :only => [:new]
  layout 'sellers/seller'

  before_action :set_seller, only: %i[new show edit update update_business_representative update_company_detail update_seller_logo remove_logo_image update_addresses]


  def new
  end

  def show
    @remaining_addresses = Address.address_types.keys - @seller.addresses.collect(&:address_type)
    @remaining_addresses.each do |address_type| @seller.addresses.build address_type: address_type end if @remaining_addresses.present?
    # this unless has nothing to do with if
    unless @seller.seller_api
      @seller_api = @seller.build_seller_api
    else
      @seller_api = @seller.seller_api
    end
  end


  def update
    @seller.update(seller_params)
    redirect_to sellers_seller_authenticated_root_path
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
    unless @seller.seller_api
      @seller_api = @seller.build_seller_api
    else
      @seller_api = @seller.seller_api
    end
  end


  def update_seller_api
    random_token = SecureRandom.hex(30)
    @seller = Seller.find(params[:profile_id])
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
    @seller_api = SellerApi.find(params[:seller_api])
    @seller = @seller_api.seller
    @seller_api.api_token = random_token
    @seller_api.save
  end

  private
  def seller_params
    params.require(:seller).permit(:first_name, :last_name, :email, :subscription_type,:account_status, :listing_status,:terms_and_conditions, :recieve_deals_via_email,
      business_representative_attributes: [:id, :full_legal_name, :email, :job_title, :date_of_birth],
      bank_detail_attributes: [:id, :currency, :country, :sort_code, :account_number, :account_number_confirmation],
      company_detail_attributes: [:id, :name, :vat_number, :country, :legal_business_name, :companies_house_registration_number, :business_industry, :website_url, :amazon_url, :ebay_url, :doing_business_as],
        addresses_attributes: [:id, :address_line_1, :address_line_2, :city, :county, :country, :postal_code, :phone_number, :address_type],
        picture_attributes: ["name", "@original_filename", "@content_type", "@headers", "_destroy", "id"],
      )
  end
  def set_seller
    @seller = Seller.includes([ :business_representative, :company_detail, :addresses ]).find(params[:id])
  end
end
