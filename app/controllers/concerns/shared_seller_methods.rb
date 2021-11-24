module SharedSellerMethods
  extend ActiveSupport::Concern

  def update_business_representative
    if seller_params[:listing_status] == 'in_active'
      # change this seller's products status to inactive
      @seller.products.where(status: :active).update(status: :inactive)
    else
      @seller.products.where(status: :inactive).update(status: :active)
    end
    @seller.update(seller_params)
    @seller.send_account_status_changed_email_to_seller
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
    @address_type = params[:seller][:addresses_attributes]["0"][:address_type]
    @address = @seller.addresses.where(address_type: @address_type).last
    flash.now[:notice] = "#{@address_type.humanize} updated successfully!"
  end

end
