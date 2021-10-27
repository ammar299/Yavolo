class Sellers::ProductsController < Sellers::BaseController
  def index
    @listing_by_status_with_count = Product.get_group_by_status_count(current_seller)
    @q = Product.ransack(params[:q])
    query = @q.result(distinct: true).page(params[:page]).per(params[:per_page].presence || 15)
    if Product.statuses.keys.include?(params[:tab]) || params[:tab]=='all' || params[:tab]=='yavolo_enabled'
      @products = query.send("#{params[:tab]}_products", current_seller)
    else
      @products = query.where(owner_id: current_seller.id, owner_type: current_seller.class.name)
    end
    @products = @products.page(params[:page]).per(params[:per_page].presence || 15)
  end

  def new
    if params[:dup_product_id].present?
      @product = duplicate_product_new(params[:dup_product_id])
    else
      @product = initialize_new_product
    end
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
      save_product_images_from_remote_urls(@product) if params[:dup_product_id].present?
      redirect_to edit_sellers_product_path(@product), notice: 'Product was successfully created.'
    else
      @delivery_options = DeliveryOption.all
      @product.owner_id = owner_params[:owner_id]
      @product.owner_type = owner_params[:owner_type]
      render action: 'new', product_id: params[:product_id]
    end
  end

  def edit
    @product = Product.friendly.find(params[:id])
    @product.pictures.build
    @product.build_seo_content if @product.seo_content.blank?
    @product.build_ebay_detail if @product.ebay_detail.blank?
    @product.build_google_shopping if @product.google_shopping.blank?
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
      redirect_to edit_sellers_product_path(@product), notice: 'Product was successfully updated.'
    else
      @delivery_options = DeliveryOption.all
      render action: 'edit'
    end
  end

  def enable_yavolo
    if params[:product][:ids].present?
      @products = Product.where(id: params[:product][:ids], yavolo_enabled: false, owner_id: current_seller.id, owner_type: current_seller.class.name).update(yavolo_enabled: true)
    end
  end

  def upload_csv
    csv_import = CsvImport.new(params.require(:csv_import).permit(:file))
    csv_import.importer_id = current_seller.id
    csv_import.importer_type = current_seller.class.name
    if csv_import.valid?
      csv_import.save
      csv_import.update({status: :uploaded})
      ImportCsvWorker.perform_async(csv_import.id)
      render json: { message: 'Your file is uploaded and you will be notified with import status.' }, status: :ok
    else
      render json: { errors: csv_import.errors.where(:file).last.message }, status: :unprocessable_entity
    end
  end

  def export_csv
    if current_seller.products.count > 50
      ExportCsvWorker.perform_async(current_seller.id, current_seller.class.name)
      redirect_to sellers_products_path, notice: 'Products export is started, You will receive a file when its completed.'
    else
      exporter = Products::Exporter.call({ owner: current_seller })
      if exporter.status
        respond_to do |format|
          format.csv { send_data exporter.csv_file, filename: "products_#{Time.zone.now.to_i}.csv" }
        end
      else
        render json: { error: exporter.errors.first.to_s }
      end
    end
  end

  def bulk_products_update
    valid_actions =['activate','yavolo_enabled','yavolo_disabled','delete','update_price','update_stock','update_discount']
    if valid_actions.include?(params[:bulk_action]) && action_required_params(params[:bulk_action]).present?
      action_params = action_required_params(params[:bulk_action])
      result = Product.where(id: action_params).update_all(status: :active) if params[:bulk_action]=='activate'
      result = Product.where(id: action_params).update_all(yavolo_enabled: true) if params[:bulk_action]=='yavolo_enabled'
      result = Product.where(id: action_params).update_all(yavolo_enabled: false) if params[:bulk_action]=='yavolo_disabled'
      result = Product.where(id: action_params).destroy_all if params[:bulk_action]=='delete'
      result =  Product.update(action_params.keys, action_params.values) if ['update_price','update_stock','update_discount'].include?(params[:bulk_action])

      updated_ids = ['update_price','update_stock','update_discount','delete'].include?(params[:bulk_action]) ? result.map(&:id) : action_params
      render json: { notice: 'updated', update_ids: updated_ids }, status: :ok
    else
      render json: { errors: ['invalid action or params are missing'] }, status: :unprocessable_entity
    end
  end



  private
    def product_params
      params.require(:product).permit(:owner_id,:owner_type,
      :title, :condition, :width, :depth, :height, :colour, :material, :brand, :keywords, :description, :price, :stock, :sku, :ean, :discount, :yavolo_enabled, :delivery_option_id,
      pictures_attributes: ["name", "@original_filename", "@content_type", "@headers", [:remote_name_url] ],
      seo_content_attributes: [:id,:title, :url, :description, :keywords],
      ebay_detail_attributes: [:id,:lifetime_sales, :thirty_day_sales, :price, :thirty_day_revenue, :mpn_number], google_shopping_attributes: [:id,:title,:price,:category,:campaign_category,:description,:exclude_from_google_feed],
      assigned_category_attributes: [:id,:category_id],
      filter_in_category_ids: [])
    end

    def owner_params
      { owner_id: current_seller.id, owner_type: current_seller.class.name }
    end

    def images_to_delete_params
      @images_to_remove ||= params[:product][:images_attributes].values.select{|h| h["_destroy"]=="1" } if params[:product][:images_attributes].present?
    end

    def duplicate_product_new(pid)
      ex_product = Product.friendly.find_by(id: pid)
      product = ex_product.present? ? ex_product.dup : initialize_new_product
      return product if ex_product.blank?
      ex_product.seo_content.present? ? product.seo_content = ex_product.seo_content.dup : product.build_seo_content
      ex_product.ebay_detail.present? ? product.ebay_detail = ex_product.ebay_detail.dup : product.build_ebay_detail
      ex_product.google_shopping.present? ? product.google_shopping = ex_product.google_shopping.dup : product.build_google_shopping
      ex_product.assigned_category.present? ? product.assigned_category = ex_product.assigned_category.dup : product.build_assigned_category
      product.pictures = ex_product.pictures.dup
      product
    end

    def initialize_new_product
      product = Product.new(owner_params)
      product.build_seo_content
      product.build_ebay_detail
      product.build_google_shopping
      product.build_assigned_category
      product
    end

    def save_product_images_from_remote_urls(product)
      if params[:product][:copy_images].present?
        images_urls = params[:product][:copy_images].map{ |e|
          {remote_name_url: "#{ENV['HOST_URL']}#{e[:remote_name_url]}"}
        }
        product.pictures_attributes=images_urls
        product.save
      end
    end

    def selected_rows_params
      @params_ary ||= params.permit(products_attributes:[:id,:marked,:stock,:price,:discount])["products_attributes"].select{|p| p["marked"].present? }
    end

    def action_required_params(action)
      case action
      when 'activate','yavolo_enabled','yavolo_disabled','delete'
        selected_rows_params.map{|p| p["id"].to_i}
      when 'update_price'
        selected_rows_params.map{|p| {id: p["id"], price: p["price"]} }.index_by{|p| p[:id]}
      when 'update_stock'
        selected_rows_params.map{|p| {id: p["id"], stock: p["stock"]} }.index_by{|p| p[:id]}
      when 'update_discount'
        selected_rows_params.map{|p| {id: p["id"], discount: p["discount"]} }.index_by{|p| p[:id]}
      end
    end


end
