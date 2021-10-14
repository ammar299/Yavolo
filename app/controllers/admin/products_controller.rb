class Admin::ProductsController < Admin::BaseController
  def index
    # @csv_import = CsvImport.new({ importer_id: current_admin.id, importer_type: 'Admin'})
    @products = Product.order(:title).page(params[:page]).per(params[:per_page].presence || 15)
  end

  def new
    @product = Product.new(owner_params)
    @product.build_seo_content
    @product.build_ebay_detail
    @product.build_google_shopping
    @delivery_options = DeliveryOption.all
  end

  def create
    @product = Product.new(product_params)
    if !@product.active? && params[:commit]== 'Publish'
      @product.status = 'active'
      @product.published_at = Time.zone.now
    else
      @product.status = 'draft'
    end

    respond_to do |format|
      if @product.save
        format.html { redirect_to edit_admin_product_path(@product), notice: 'Product was successfully created.' }
      else
        @delivery_options = DeliveryOption.all
        @product.owner_id = owner_params[:owner_id]
        @product.owner_type = owner_params[:owner_type]
        format.html { render action: 'new' }
      end
    end
  end

  def edit
    @product = Product.friendly.find(params[:id])
    @delivery_options = DeliveryOption.all
  end

  def update
    @product = Product.friendly.find(params[:id])
    # TODO: handle statuses
    if !@product.active? && params[:commit]== 'Publish'
      @product.status = 'active'
      @product.published_at = Time.zone.now
    elsif params[:commit]== 'Save Draft'
      @product.status = 'draft'
    end

    respond_to do |format|
      if @product.update(product_params)
        format.html { redirect_to edit_admin_product_path(@product), notice: 'Product was successfully updated.' }
      else
        @delivery_options = DeliveryOption.all
        format.html { render action: 'edit' }
      end
    end
  end

  def upload_csv
    csv_import = CsvImport.new(params.require(:csv_import).permit(:file))
    csv_import.importer_id = current_admin.id
    csv_import.importer_type = 'Admin'
    if csv_import.valid?
      csv_import.save
      csv_import.update({status: :uploaded})
      ImportCsvWorker.perform_async(csv_import.id)
      render json: { message: 'Your file is uploaded and you will be notified with import status.' }, status: :ok
    else
      render json: { errors: csv_import.errors.where(:file).last.message }, status: :unprocessable_entity
    end
  end

  private
    def product_params
      params.require(:product).permit(:owner_id,:owner_type,
      :title, :condition, :width, :depth, :height, :colour, :material, :brand, :keywords, :description, :price, :stock, :sku, :ean, :discount, :yavolo_enabled, :delivery_option_id,
      pictures_attributes: ["name", "@original_filename", "@content_type", "@headers", "_destroy", "id"],
      seo_content_attributes: [:title, :url, :description, :keywords],
      ebay_detail_attributes: [:lifetime_sales, :thirty_day_sales, :price, :thirty_day_revenue, :mpn_number], google_shopping_attributes: [:title,:price,:category,:campaign_category,:description,:exclude_from_google_feed])
    end

    def owner_params
      { owner_id: current_admin.id, owner_type: 'Admin' }
    end
end
