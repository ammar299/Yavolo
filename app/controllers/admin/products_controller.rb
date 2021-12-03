class Admin::ProductsController < Admin::BaseController
  before_action :format_price_value, only: %i[create update]
  include SharedProductMethods
  def index
    parse_sort_param_to_array
    @q = Product.ransack(params[:q])
    @products = @q.result(distinct: true).select('products.*, lower(products.title)')
    @products = @products.where(status: filter_by_statuses) if filter_by_statuses.present?
    @products = @products.where(yavolo_enabled: true) if params[:yavolo_enabled]=='1'
    @products = @products.order(created_at: :desc) if params.dig(:q, :s).blank?
    @total_count = @products.size
    @products = @products.page(params[:page]).per(params[:per_page].presence || 15)
  end

  def new
    if params[:dup_product_id].present?
      @product = duplicate_product_new(params[:dup_product_id])
    else
      @product = initialize_new_product
    end
    @delivery_options = admins_delivery_templates
  end

  def create
    @product = Product.new(product_params)
    if !@product.active? && params[:commit]== 'APPROVE & PUBLISH'
      @product.status = 'active'
      @product.published_at = Time.zone.now
    elsif params[:commit]== 'SAVE DRAFT'
      @product.status = 'draft'
    end

    if @product.seo_content.title.present? || @product.seo_content.description.present?
      @product.check_for_seo_content_uniqueness = true
    end

    if @product.save
      messages = @product.seo_content.assign_meta_title_and_description
      save_product_images_from_remote_urls(@product) if params[:dup_product_id].present?
      redirect_to admin_products_path, notice: messages.join(". ")
    else
      if params[:dup_product_id].present?
        ref_product = Product.where(id: params[:dup_product_id]).first
        @product.pictures = ref_product.pictures.dup if ref_product.present?
      end
      @delivery_options = admins_delivery_templates
      render action: 'new', product_id: params[:product_id]
    end

  end

  def edit
    @product = Product.friendly.find(params[:id])
    @product.pictures.build
    @product.build_seo_content if @product.seo_content.blank?
    @product.build_ebay_detail if @product.ebay_detail.blank?
    @product.build_google_shopping if @product.google_shopping.blank?
    @product.build_assigned_category if @product.assigned_category.blank?
    @delivery_options = admin_and_current_product_sellers_delivery_templates
  end

  def update
    @product = Product.friendly.find(params[:id])
    if !@product.active? && params[:commit]== 'APPROVE & PUBLISH'
      @product.status = @product.owner_type == "Seller" && @product.owner.in_active? ? 'inactive' : 'active'
      @product.published_at = Time.zone.now
    elsif params[:commit]== 'SAVE DRAFT'
      @product.status = 'draft'
    end

    if @product.update(product_params)
      if images_to_delete_params.present?
        @product.pictures_attributes = images_to_delete_params
        @product.save
      end
      redirect_to admin_products_path, notice: 'Product was successfully updated.'
    else
      @delivery_options = admin_and_current_product_sellers_delivery_templates
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

  def export_csv
    product_ids = get_products()
    # all_products = []
    # product_ids.each do |product|
    #   product = Product.find(product)
    #   all_products << product
    # end
    # if all_products.count > 50
      ExportCsvWorker.perform_async(current_admin.id, current_admin.class.name,product_ids)
      redirect_to admin_products_path, notice: 'Products export is started, You will receive a file when its completed.'
    # else
    #   exporter = Products::Exporter.call({ owner: all_products })
    #   if exporter.status
    #     respond_to do |format|
    #       format.csv { send_data exporter.csv_file, filename: "products_#{Time.zone.now.to_i}.csv" }
    #     end
    #   else
    #     render json: { error: exporter.errors.first.to_s }
    #   end
    # end
  end

  def get_products
    products = []
    product_ids = params[:products].split(",")
    product_ids.each do |product|
      products << product.to_i
    end
    return products
  end

  def preview_listing
    session[:preview_listing] = { product: params }
    render json: { product_name: params[:title].parameterize }, status: :ok
  end

  private
    def current_user
      current_admin
    end

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
      { owner_id: current_admin.id, owner_type: 'Admin' }
    end

    def images_to_delete_params
      @images_to_remove ||= params[:product][:images_attributes].values.select{|h| h["_destroy"]=="1" } if params[:product][:images_attributes].present?
    end

    def duplicate_product_new(pid)
      ex_product = Product.friendly.find_by(id: pid)
      product = ex_product.present? ? ex_product.dup : initialize_new_product
      return product if ex_product.blank?
      product.seo_content = product.build_seo_content
      ex_product.ebay_detail.present? ? product.ebay_detail = ex_product.ebay_detail.dup : product.build_ebay_detail
      ex_product.google_shopping.present? ? product.google_shopping = ex_product.google_shopping.dup : product.build_google_shopping
      ex_product.assigned_category.present? ? product.assigned_category = ex_product.assigned_category.dup : product.build_assigned_category
      product.pictures = ex_product.pictures.dup
      product
    end

    def initialize_new_product
      product = Product.new
      product.build_seo_content
      product.build_ebay_detail
      product.build_google_shopping
      product.build_assigned_category
      product.yavolo_enabled = true
      product
    end

    def save_product_images_from_remote_urls(product)
      if params[:product][:copy_images].present?
        images_urls = params[:product][:copy_images].map{ |e|
          if Rails.env.production?
            {remote_name_url: "#{e[:remote_name_url]}"}
          else
            {remote_name_url: "#{ENV['HOST_URL']}#{e[:remote_name_url]}"}
          end
        }
        product.pictures_attributes=images_urls
        product.save
      end
    end

    def filter_by_statuses
      Product.statuses.keys&params[:statuses].split(',') if params[:statuses].present?
    end

    def format_price_value
      price = params[:product][:price].split('£').reject(&:blank?).join('').delete(',') if params[:product][:price].present?
      params[:product][:price] = price if price.present?
    end

    def admins_delivery_templates
      DeliveryOption.left_outer_joins(:products).select("delivery_options.*, COUNT(products.*) AS product_count")
      .where(delivery_optionable_type: 'Admin').group(:id).order('product_count DESC')
    end

    def admin_and_current_product_sellers_delivery_templates
      DeliveryOption.left_outer_joins(:products).select("delivery_options.*, COUNT(products.*) AS product_count")
      .where("delivery_optionable_type = 'Admin' OR (delivery_optionable_id = ? AND delivery_optionable_type = ?)", @product.owner_id, @product.owner_type||'Admin' )
      .group(:id).order('product_count DESC')
    end
end
