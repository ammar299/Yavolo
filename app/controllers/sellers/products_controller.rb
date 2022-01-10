class Sellers::ProductsController < Sellers::BaseController
  before_action :validate_seller_dashboard!
  before_action :format_price_value, only: %i[create update]

  include SharedProductMethods
  include ParseSortParam

  def index
      # listing_of_seller_yavolo_bundles
      parse_sort_param_to_array
      @listing_by_status_with_count = Product.get_group_by_status_count(current_seller)
      @q = Product.ransack(params[:q])
      query = @q.result(distinct: true).select('products.*, lower(products.title)')
      ### manage yavolo for seller start  //please donot remove this code
      # if params[:tab] == "manage_yavolos"
      @yavolo_bundles = YavoloBundle.seller_yavolo_bundles(current_seller).where(products: {id: @q.result.ids})
      @yavolo_bundles = YavoloBundle.where(id: @yavolo_bundles.ids)
      @yavolo_bundles = @yavolo_bundles.order(created_at: :desc) if params.dig(:q, :s).blank?
      @total_count = @yavolo_bundles.size
      @yavolo_bundles = @yavolo_bundles.page(params[:page]).per(params[:per_page].presence || 15)
      # end
      ### manage yavolo for seller end
      if Product.statuses.keys.include?(params[:tab]) || params[:tab]=='all' || params[:tab]=='yavolo_enabled'
        @products = query.send("#{params[:tab]}_products", current_seller)
      else
        @products = query.where(owner_id: current_seller.id, owner_type: current_seller.class.name)
      end
      @products = @products.where(yavolo_enabled: true) if params[:yavolo_enabled]=='1'
      @products = @products.order(created_at: :desc) if params.dig(:q, :s).blank?
      @products = @products.page(params[:page]).per(params[:per_page].presence || 15)
  end

  def new
    if current_seller.listing_status == 'in_active'
      flash[:notice] = "You are not eligible to create product"
      redirect_to sellers_products_path
    elsif current_seller.holiday_mode == true
      flash[:notice] = "Your account is on holiday mode"
      redirect_to sellers_products_path
    else
      if params[:dup_product_id].present?
        @product = duplicate_product_new(params[:dup_product_id])
      else
        @product = initialize_new_product
      end
    end
    @delivery_options = seller_and_admins_delivery_templates
  end

  def create
    @product = Product.new(product_params)
    if !@product.active? && params[:commit]== 'APPROVE & PUBLISH'
      @product.status = 'pending'
    elsif params[:commit]== 'SAVE DRAFT'
      @product.status = 'draft'
    end

    if @product.save
      save_product_images_from_remote_urls(@product) if params[:dup_product_id].present?
      @product.update_featured_image(params[:featured_image])
      url_path = current_seller.products.count == 1? sellers_seller_authenticated_root_path : sellers_products_path
      redirect_to url_path, notice: 'Product was successfully created.'
    else
      if params[:dup_product_id].present?
        ref_product = Product.where(id: params[:dup_product_id]).first
        @product.pictures = ref_product.pictures.dup if ref_product.present?
      end
      @delivery_options = seller_and_admins_delivery_templates
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
    @product.build_assigned_category if @product.assigned_category.blank?
    @delivery_options = seller_and_admins_delivery_templates
  end

  def update
    @product = Product.friendly.find(params[:id])
    if !@product.active? && params[:commit]== 'APPROVE & PUBLISH'
      @product.status = 'pending'
    elsif params[:commit]== 'SAVE DRAFT'
      @product.status = 'draft'
    end

    if @product.update(product_params)
      if images_to_delete_params.present?
        @product.pictures_attributes = images_to_delete_params
        @product.save
      end
      @product.update_featured_image(params[:featured_image])
      redirect_to sellers_products_path, notice: 'Product was successfully updated.'
    else
      @delivery_options = seller_and_admins_delivery_templates
      render action: 'edit'
    end
  end


  def upload_csv
    product_status = params[:product_status] if params[:product_status].present?
    csv_import = CsvImport.new(params.require(:csv_import).permit(:file))
    csv_import.importer_id = current_seller.id
    csv_import.importer_type = current_seller.class.name
    if csv_import.valid?
      csv_import.save
      csv_import.update({status: :uploaded})
      ImportCsvWorker.perform_async(csv_import.id,product_status)
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
      ExportCsvWorker.perform_async(current_seller.id, current_seller.class.name, product_ids)
      redirect_to sellers_products_path, notice: 'Products export is started, You will receive a file when its completed.'
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


  def update_field
    permitted_params = params.require(:product).permit(:id,:value,:action)
    product = Product.where(id: params[:id],owner_id: current_seller.id,owner_type: current_seller.class.name).first
    if product.present?
      if permitted_params[:action]=='update_price' && product.update(price: permitted_params[:value].gsub("£","").gsub(",","")) || permitted_params[:action]=='update_stock' &&  product.update(stock: permitted_params[:value].to_i) || permitted_params[:action]=='update_discount' && product.update(discount: permitted_params[:value].to_d)
        render json: { msg: 'value updated successfully' }, status: :ok
      else
        render json: { errors: ['value can not updated'] }, status: :unprocessable_entity
      #   product.update(price: permitted_params[:value].gsub!('£',"").to_d) if permitted_params[:action]=='update_price'
      #   product.update(stock: permitted_params[:value].to_i) if permitted_params[:action]=='update_stock'
      #   product.update(discount: permitted_params[:value].to_d) if permitted_params[:action]=='update_discount'
      end
    else
      render json: { errors: ['product not found'] }, status: :unprocessable_entity
    end
  end

  def preview_listing
    session[:preview_listing] = { product: params }
    render json: { product_handle: params[:product_handle] }, status: :ok
  end


  private
    def current_user
      current_seller
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

    def seller_and_admins_delivery_templates
      DeliveryOption.left_outer_joins(:products).select("delivery_options.*, COUNT(products.*) AS product_count")
      .where("delivery_optionable_type = 'Admin' OR (delivery_optionable_id = ? AND delivery_optionable_type = ?)", current_seller.id, 'Seller')
      .group(:id).order('product_count DESC')
    end

    def format_price_value
      price = params[:product][:price].split('£').reject(&:blank?).join('').delete(',') if params[:product][:price].present?
      params[:product][:price] = price if price.present?
    end

    def listing_of_seller_yavolo_bundles
      @yavolo_bundles = @q.result(distinct: true)
        # byebug
      # if @y.statuses.keys.include?(params[:statuses])
      #   @yavolo_bundles = @y.send("status_#{params[:statuses]}")
      # elsif params[:q].present?
      #   if params[:q][:s].include?("products_in_yavolo")
      #     byebug
      #     @yavolo_bundles =   @y.order("products asc")
      #   end
      #   if params[:q][:s].include?("yavolo_total")
      #     @yavolo_bundles = @y.order("yavolo_total asc") if params[:q][:s].include?("asc")
      #     @yavolo_bundles = @y.order("yavolo_total desc") if params[:q][:s].include?("desc")
      #   end
      # else
      #   @yavolo_bundles = @y
      # end
      # byebug
      # @yavolo_bundles = @q.result(distinct: true)''
      # byebug
      # @yavolo_bundles = @q.result(distinct: true)  if params[:csfname].present?
      # @yavolo_bundles = @yavolo_bundles.order(created_at: :desc) if params.dig(:q, :s).blank?
      # @total_count = @yavolo_bundles.size
      @yavolo_bundles = @yavolo_bundles.page(params[:page]).per(params[:per_page].presence || 15)
    end

end
