class Sellers::ProfilesController < Sellers::BaseController
  layout 'application', :only => [:new]
  layout 'sellers/seller', except: %[new]

  before_action :set_seller, only: %i[new show edit update update_business_representative update_company_detail update_seller_logo remove_logo_image update_addresses holiday_mode confirm_reset_password_token reset_password_token]
  before_action :set_delivery_template, only: %i[confirm_delete destroy_delivery_template]


  def new
  end

  def show
    @delivery_options = current_seller.delivery_options
    @remaining_addresses = Address.address_types.keys - @seller.addresses.collect(&:address_type)
    @remaining_addresses.each do |address_type| @seller.addresses.build address_type: address_type end if @remaining_addresses.present?
    @seller_apis = @seller.seller_apis
  end

  def search_delivery_options
    if params[:search].present?
      @delivery_options = current_seller.delivery_options.global_search(params[:search])
    else 
      @delivery_options = current_seller.delivery_options
    end
  end


  def update
    @seller.update(seller_params)
    redirect_to sellers_seller_authenticated_root_path, flash: { notice: "Seller updated successfully" }
  end

  def update_business_representative
    @seller.update(seller_params)
    flash.now[:notice] = 'Business Representative updated successfully!'
  end

  def update_company_detail
    @seller.update(seller_params)
    flash.now[:notice] = 'Company Detail updated successfully!'
  end

  def update_seller_logo
    @seller.update(seller_params)
    flash.now[:notice] = 'Seller Logo updated successfully!'
  end
    
  def remove_logo_image
    @seller.picture.destroy if @seller.picture.present?
    flash.now[:alert] = 'Seller Logo removed successfully!'
  end

  def update_addresses
    @seller.update(seller_params)
    @address_type = params[:seller][:addresses_attributes]["0"][:address_type]
    @address = @seller.addresses.where(address_type: @address_type).last
    flash.now[:notice] = "#{@address_type.humanize} updated successfully!"
  end

  def holiday_mode
    @seller.update(holiday_mode_params)
    text = @seller.holiday_mode == true ? "Enabled holiday mode successfully" : "Disabled holiday mode successfully"
    flash.now[:notice] = "#{text}"
  end

  def reset_password_token
    raw, hashed = Devise.token_generator.generate(Seller, :reset_password_token)
    @seller.reset_password_token = hashed
    @seller.reset_password_sent_at = Time.now.utc
    if @seller.save
      Devise::Mailer.reset_password_instructions(@seller, raw).deliver_now
      flash.now[:notice] = "Reset password sent to your email successfully!"
    end
  end

  def destroy_delivery_template
    @delivery_option.destroy
    @delivery_options = current_seller.delivery_options
    flash.now[:notice] = "Delivery template deleted successfully!"
  end

  def manage_returns_and_terms
    if current_seller.return_and_term.present?
      current_seller.return_and_term.update(returns_and_terms_params)
      flash.now[:notice] = 'Return and Term has been updated successfully!'
    else
      current_seller.create_return_and_term(returns_and_terms_params)
      flash.now[:success] = 'Return and Term has been created successfully!'
    end
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

  def holiday_mode_params
    params.require(:seller).permit(:holiday_mode)
  end

  def returns_and_terms_params
    params.require(:return_and_term).permit(:duration, :email_format, :authorisation_and_prepaid, :instructions)
  end

  def set_seller
    @seller = Seller.includes([ :business_representative, :company_detail, :addresses ]).find(params[:id])
  end

  def set_delivery_template
    @delivery_option = DeliveryOption.find(params[:id])
  end
end
