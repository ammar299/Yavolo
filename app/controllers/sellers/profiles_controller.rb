class Sellers::ProfilesController < Sellers::BaseController
  layout 'application', :only => [:new]
  layout 'sellers/seller', except: %[new]
  include SharedSellerMethods

  before_action :set_seller, except: %i[search_delivery_options confirm_delete destroy_delivery_template manage_returns_and_terms]
  before_action :set_delivery_template, only: %i[confirm_delete destroy_delivery_template]
  before_action :get_action_url, only: %i[show]


  def new
  end

  def show
    @seller = current_seller
    @q = current_seller.delivery_options.ransack(params[:q])
    if params[:q].present? && params[:q][:name_or_ships_name_cont].present?
      @delivery_options = @q.result.includes(:ships)
    else
      @delivery_options = @q.result
    end
    @remaining_addresses = Address.address_types.keys - @seller.addresses.collect(&:address_type)
    @remaining_addresses.each do |address_type| @seller.addresses.build address_type: address_type end if @remaining_addresses.present?
    @seller_apis = @seller.seller_apis
    @payment_methods = @seller.seller_payment_methods if @seller.seller_payment_methods.present?
    @return_and_term = @seller.return_and_term || @seller.build_return_and_term
  end

  def seller_login_setting_update
    params[:seller][:timeout].present? ? params[:seller][:timeout] : params[:seller][:timeout] = nil
    params[:seller][:two_factor_auth] == '1' ? params[:seller][:two_factor_auth] = true : params[:seller][:two_factor_auth] = false
    if params[:seller][:current_password].blank? && params[:seller][:password].blank? && params[:seller][:password_confirmation].blank?
      @seller = @seller.update(seller_params)
      flash.now[:notice] = "Login details updated successfully"
    elsif @seller.valid_password?(params[:seller][:current_password])
      if  params[:seller][:current_password].present? && params[:seller][:password].present? && params[:seller][:password_confirmation].present? && params[:seller][:remember_me] == "0"
        # if @seller.valid_password?(params[:seller][:current_password])
        if params[:seller][:password_confirmation] == params[:seller][:password] && @seller.valid_password?(params[:seller][:current_password])
          @seller.update(seller_login_params)
          flash.now[:notice] = "Login details updated successfully"
          render js: "window.location = '#{new_seller_session_path}'"
        else
           flash.now[:notice] = "Password did not matched"
        end
      elsif params[:seller][:password_confirmation].present? && params[:seller][:password].present? && params[:seller][:current_password].present?
        if params[:seller][:password_confirmation] == params[:seller][:password] && @seller.valid_password?(params[:seller][:current_password])
          resource = current_seller
          @seller.update(seller_login_params)
          flash.now[:notice] = "Login details updated successfully"
          resource.after_database_authentication
          bypass_sign_in @seller, scope: :seller
        else
          flash.now[:notice] = "Password did not matched"
        end
      elsif params[:seller][:current_password].present? && params[:seller][:password].blank? && params[:seller][:password_confirmation].blank?
        @seller.update(seller_params)
        flash.now[:notice] = "Login details updated successfully"
      else
        @seller.update(seller_params)
        flash.now[:notice] = "Login details updated successfully"
      end
    else
      flash.now[:notice] = "Incorrect current password"
    end
  end

  def update
    @seller.update(seller_params)
    redirect_to sellers_seller_authenticated_root_path, flash: { notice: "Seller updated successfully" }
  end

  def skip_success_hub_steps
    return_address = get_return_address
    invoice_address = get_invoice_address
    if return_address.present? && invoice_address.present? && @seller.bank_detail.present? && @seller&.paypal_detail&.integration_status? && @seller.products.count > 0
      @seller.update(skip_success_hub_steps: params[:skip_success_steps])
    end
    redirect_to sellers_seller_authenticated_root_path
  end

  def reviewed_login_screen
    @seller.update(reviewed_login_screen: true) unless @seller.reviewed_login_screen
  end

  def holiday_mode
    if holiday_mode_params[:holiday_mode] == 0 || holiday_mode_params[:holiday_mode] == "0"
      #change this seller's products status to inactive
      @seller.products.where(status: :inactive).update(status: :active)
    else
      @seller.products.where(status: :active).update(status: :inactive)
    end
    @seller.update(holiday_mode_params)
    text = @seller.holiday_mode == true ? "Enabled holiday mode successfully" : "Disabled holiday mode successfully"
    flash.now[:notice] = "#{text}"
    SellerMailer.with(to: @seller.email.downcase).send_holiday_mode_email(@seller).deliver_now
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
      flash.now[:notice] = 'Return and Term has been created successfully!'
    end
  end

  private
  def seller_params
    params.require(:seller).permit(:first_name, :last_name, :email, :subscription_type,:account_status, :listing_status,:terms_and_conditions, :recieve_deals_via_email, :contact_number, :remember_me, :timeout, :two_factor_auth, :recovery_email,
      business_representative_attributes: [:id, :full_legal_name, :email, :job_title, :date_of_birth],
      bank_detail_attributes: [:id, :currency, :country, :sort_code, :account_number, :account_number_confirmation],
      company_detail_attributes: [:id, :name, :vat_number, :country, :legal_business_name, :companies_house_registration_number, :business_industry, :website_url, :amazon_url, :ebay_url, :doing_business_as],
        addresses_attributes: [:id, :address_line_1, :address_line_2, :city, :county, :country, :postal_code, :phone_number, :address_type],
        picture_attributes: ["name", "@original_filename", "@content_type", "@headers", "_destroy", "id"],
      )
  end

  def get_return_address
    @seller.addresses.select do |address| address.address_type == 'return_address' end
  end

  def get_invoice_address
    @seller.addresses.select do |address| address.address_type == 'invoice_address' end
  end

  def seller_login_params
    params.require(:seller).permit( :email, :password, :confirmation_password, :contact_number, :remember_me, :timeout, :two_factor_auth, :recovery_email)
  end

  def holiday_mode_params
    params.require(:seller).permit(:holiday_mode)
  end

  def returns_and_terms_params
    params.require(:return_and_term).permit(:duration, :email_format, :authorisation_and_prepaid, :instructions)
  end

  def set_seller
    @seller = Seller.includes([ :business_representative, :company_detail, :addresses ]).find_by(id: params[:id])
    if current_seller != @seller
      redirect_to sellers_seller_authenticated_root_path
    end
  end

  def set_delivery_template
    @delivery_option = DeliveryOption.find(params[:id])
  end

  def get_action_url
    @seller = current_seller
    @action_url = @seller&.paypal_detail&.seller_action_url
    if !@action_url.present? || !@seller&.paypal_detail&.integration_status
      @action_url = Sellers::PaypalIntegrationService.call({seller: current_seller})
    end
  end

end
