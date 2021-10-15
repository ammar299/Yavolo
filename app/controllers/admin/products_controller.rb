class Admin::ProductsController < Admin::BaseController
  def index
    @q = Product.ransack(params[:q])
    if params[:q].present? && params[:q][:price_low_high_cont].present?
      @products = Product.where("price >= ?", params[:q][:price_low_high_cont]).order("price asc")
      @products= @products.page(params[:page]).per(params[:per_page].presence || 15)
    elsif params[:q].present? &&  params[:q][:price_high_low_cont].present?
      @products = Product.where("price <= ?", params[:q][:price_high_low_cont]).order("price desc")
      @products = @products.page(params[:page]).per(params[:per_page].presence || 15)
    elsif params[:q].present? &&  params[:q][:title_a_z_cont].present?
      @products = Product.order("title asc")
      @products = @products.page(params[:page]).per(params[:per_page].presence || 15)
    elsif params[:q].present? &&  params[:q][:title_a_z_cont].present?
      @products = Product.order("title desc")
      @products = @products.page(params[:page]).per(params[:per_page].presence || 15)
    else
      @q = Product.ransack(params[:q])
      @products = @q.result(distinct: true).page(params[:page]).per(params[:per_page].presence || 15)      
    end
    # @products = Product.order(:title).page(params[:page]).per(params[:per_page].presence || 15)
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

    if @product.save
      redirect_to edit_admin_product_path(@product), notice: 'Product was successfully created.'
    else
      @delivery_options = DeliveryOption.all
      @product.owner_id = owner_params[:owner_id]
      @product.owner_type = owner_params[:owner_type]
      render action: 'new'
    end

  end

  def edit
    @product = Product.friendly.find(params[:id])
    @product.pictures.build
    @delivery_options = DeliveryOption.all
  end

  def update
    @product = Product.friendly.find(params[:id])
    if !@product.active? && params[:commit]== 'PUBLISH'
      @product.status = 'active'
      @product.published_at = Time.zone.now
    elsif params[:commit]== 'SAVE DRAFT'
      @product.status = 'draft'
    end

    if @product.update(product_params)
      if images_to_delete_params.present?
        @product.pictures_attributes = images_to_delete_params
        @product.save
      end
      redirect_to edit_admin_product_path(@product), notice: 'Product was successfully updated.'
    else
      @delivery_options = DeliveryOption.all
      render action: 'edit'
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
      pictures_attributes: ["name", "@original_filename", "@content_type", "@headers"],
      seo_content_attributes: [:id,:title, :url, :description, :keywords],
      ebay_detail_attributes: [:id,:lifetime_sales, :thirty_day_sales, :price, :thirty_day_revenue, :mpn_number], google_shopping_attributes: [:id,:title,:price,:category,:campaign_category,:description,:exclude_from_google_feed])
    end

    def owner_params
      { owner_id: current_admin.id, owner_type: 'Admin' }
    end

    def images_to_delete_params
      @images_to_remove ||= params[:product][:images_attributes].values.select{|h| h["_destroy"]=="1" } if params[:product][:images_attributes].present?
    end
end
