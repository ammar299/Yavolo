class Sellers::Auth::SignUpStepsController < Sellers::BaseController
  layout 'application'
  before_action :set_progress, only: [:show]
  include Wicked::Wizard
  steps :add_company_detail, :add_company_address, :add_business_representative, :add_business_representative_address, :bank_details, :final_step


  def show
    @seller = current_seller
    unless params[:edit].present? && params[:edit] == "true"
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
        skip_step if @seller.addresses.where(address_type: 'business_representative_address').first.present?
      when :bank_details
        jump_to(:add_company_detail) if @seller.company_detail.nil?
        jump_to(:add_company_address) if @seller.addresses.where(address_type: 'business_address').first.nil?
        jump_to(:add_business_representative) if @seller.business_representative.nil?
        skip_step if @seller.bank_detail.present?
      when :final_step
        jump_to(:add_company_detail) if @seller.company_detail.nil?
        jump_to(:add_company_address) if @seller.addresses.where(address_type: 'business_address').first.nil?
        jump_to(:add_business_representative) if @seller.business_representative.nil?
        jump_to(:add_business_representative_address) if @seller.addresses.where(address_type: 'business_representative_address').first.nil?
        jump_to(:bank_details) if @seller.bank_detail.nil?
      end
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
    params.require(:seller).permit(:first_name, :last_name, :email, :subscription_type,:account_status, :listing_status,:terms_and_conditions, :recieve_deals_via_email,
      business_representative_attributes: [:id, :full_legal_name, :email, :job_title, :date_of_birth],
      bank_detail_attributes: [:id, :currency, :country, :sort_code, :account_number, :account_number_confirmation],
      company_detail_attributes: [:id, :name, :vat_number, :country, :legal_business_name, :companies_house_registration_number, :business_industry, :website_url, :amazon_url, :ebay_url, :doing_business_as],
        addresses_attributes: [:id, :address_line_1, :address_line_2, :city, :county, :country, :postal_code, :phone_number, :address_type],
        picture_attributes: ["name", "@original_filename", "@content_type", "@headers", "_destroy", "id"],
      )
  end

  def set_progress
    if wizard_steps.any? && wizard_steps.index(step).present?
      @progress = ((wizard_steps.index(step) + 1).to_d / wizard_steps.count.to_d) * 100
    else
      @progress = 0
    end
  end
end
