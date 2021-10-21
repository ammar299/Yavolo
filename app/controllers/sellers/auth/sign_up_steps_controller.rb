class Sellers::Auth::SignUpStepsController < Sellers::BaseController
  layout 'application'
  include Wicked::Wizard
  steps :add_company_detail, :add_company_address, :add_business_representative, :add_business_representative_address


  def show
    @seller = current_seller
    case step
    when :add_company_detail
      skip_step if @seller.company_detail.present?
    when :add_company_address
      jump_to(:add_company_detail) if @seller.company_detail.nil?
      skip_step if @seller.addresses.where(address_type: 'business_address').first.present?
    when :add_business_representative
      jump_to(:add_company_detail) if @seller.company_detail.nil?
      jump_to(:add_company_address) if @seller.addresses.where(address_type: 'business_address').first.nil?
      skip_step if @seller.business_representative.present?
    when :add_business_representative_address
      jump_to(:add_company_detail) if @seller.company_detail.nil?
      jump_to(:add_company_address) if @seller.addresses.where(address_type: 'business_address').first.nil?
      jump_to(:add_business_representative) if @seller.business_representative.nil?

    end
    render_wizard
  end

  def update
    @seller = current_seller
    @seller.update(seller_params)
    render_wizard @seller
  end


  private
  def redirect_to_finish_wizard(options = nil, params = nil)
    redirect_to sellers_seller_authenticated_root_path
  end

  def seller_params
    params.require(:seller).permit(:first_name, :last_name, :email, :subscription_type,:account_status, :listing_status,
        business_representative_attributes: [:id, :full_legal_name, :email, :job_title, :date_of_birth],
        company_detail_attributes: [:id, :name, :vat_number, :country, :legal_business_name, :companies_house_registration_number, :business_industry, :website_url, :amazon_url, :ebay_url, :doing_business_as],
        addresses_attributes: [:id, :address_line_1, :address_line_2, :city, :county, :country, :postal_code, :phone_number, :address_type],
        picture_attributes: ["name", "@original_filename", "@content_type", "@headers", "_destroy", "id"],
      )
  end
end
