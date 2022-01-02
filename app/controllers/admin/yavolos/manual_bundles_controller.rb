class Admin::Yavolos::ManualBundlesController < Admin::BaseController

  before_action :format_price_params, only: %i[new edit create_bundle update_bundle]

  def index
    @q = YavoloBundle.includes(yavolo_bundle_products: [:product]).ransack(params[:q])
    @yavolo_bundles = @q.result(distinct: true)
    @yavolo_bundles = @yavolo_bundles.order(created_at: :desc) if params.dig(:q, :s).blank?
    @total_count = @yavolo_bundles.size
    @yavolo_bundles = @yavolo_bundles.page(params[:page]).per(params[:per_page].presence || 15)
  end

  def new
    @yavolo_bundle = YavoloBundle.new(yavolo_params_for_new)
    @products = []
    @featured_images = []
    params[:products].each do |p|
      product = Product.find_by(id: p[:id])
      next unless product.present?
      @products << product
      @yavolo_bundle.yavolo_bundle_products << YavoloBundleProduct.new(product: product, price: view_context.strip_currency_from_price(p[:discount_price]))
      @featured_images << product.get_featured_image
    end
    @featured_images.compact!
    @yavolo_bundle.build_seo_content
    @yavolo_bundle.build_google_shopping
  end

  def edit
    @yavolo_bundle = YavoloBundle.find_by(id: params[:yavolo_bundle_id])
    if @yavolo_bundle.present?
      @products = []
      @featured_images = @yavolo_bundle.pictures
      params[:products].each do |p|
        product = Product.find_by(id: p[:id])
        next unless product.present?
        @products << product
        # Add newly added products to bundle to its association
        unless  YavoloBundleProduct.find_by(yavolo_bundle: @yavolo_bundle, product: product).present?
          @yavolo_bundle.yavolo_bundle_products << YavoloBundleProduct.new(product: product, price: view_context.strip_currency_from_price(p[:discount_price]))
        end
      end
      @yavolo_bundle.assign_attributes(yavolo_params_for_new)
      @yavolo_bundle.build_seo_content if @yavolo_bundle.seo_content.blank?
      @yavolo_bundle.build_google_shopping if @yavolo_bundle.google_shopping.blank?
    else
      redirect_to admin_yavolos_manual_bundles_path, notice: "Bundle not found"
    end
  end

  def create_bundle
    @yavolo_bundle = YavoloBundle.new(manual_bundle_params)
    @products = []
    update_associated_products
    assign_correct_status_to_bundle

    if @yavolo_bundle.save
      save_product_images_from_remote_urls(@yavolo_bundle)
      redirect_to admin_yavolos_manual_bundles_path, notice: "Bundle created successfully"
    else
      render :new
    end
  end

  def update_bundle
    @yavolo_bundle = YavoloBundle.find(params[:yavolo_bundle_id])
    @products = []
    update_associated_products
    assign_correct_status_to_bundle
    if @yavolo_bundle.update(manual_bundle_params)
      if images_to_delete_params.present?
        @yavolo_bundle.pictures_attributes = images_to_delete_params
        @yavolo_bundle.save
      end
      redirect_to admin_yavolos_manual_bundles_path, notice: "Bundle updated successfully"
    else
      @featured_images = @yavolo_bundle.pictures
      render :edit
    end
  end

  def add_yavolos
    @yavolo_bundle = YavoloBundle.find_by(id: params[:yavolo_bundle_id]) if params[:yavolo_bundle_id].present?
    @q = Product.ransack(params[:q])
    @products = @q.result(distinct: true).select('products.*, lower(products.title)')
    @products = @products.active.yavolo_enabled.order(created_at: :desc).page(params[:page]).per(params[:per_page].presence || 15)
    respond_to do |format|
      format.html
      format.js
    end
  end

  def yavolo_product_details
    product = Product.find_by(id: params[:product_id])
    render json: {raw_html: render_to_string(partial: "admin/yavolos/manual_bundles/summary/yavolo_product_item_summary", locals: {product: product}, formats: [:html]),
                  product_id: product.id
    }
  end

  def yavolo_least_stock_value
    stock_value = nil
    if params[:product_ids].present?
      productWithLeastStock = Product.where(id: params[:product_ids].split(",")).order(stock: :asc).first
      stock_value = productWithLeastStock.stock
    end
    render json: {stockValue: stock_value}, status: :ok
  end

  def export_yavolos
    if params[:yavolos]&.split(",")&.count <= 50
      respond_to do |format|
        format.html
        format.csv { send_data YavoloBundles::Exporter.call(params[:yavolos]).csv_file, filename: "#{Date.today}-export-yavolos.csv"}
      end
    else
      ExportYavolosToEmailWorker.perform_async(params[:yavolos])
    end
  end

  def import_yavolos
    csv_import = CsvImport.new(params.permit(:file))
    csv_import.importer_id = current_admin.id
    csv_import.importer_type = 'Admin'
    if csv_import.valid?
      csv_import.status = :uploaded
      csv_import.save
      ImportYavolosWorker.perform_async(csv_import.id)
      render json: { message: 'Your file is uploaded and you will be notified with import status.' }, status: :ok
    else
      render json: { errors: csv_import.errors.where(:file).last.message }, status: :unprocessable_entity
    end
  end

  def remove_product_bundle_association
    bundle_id = params[:manual_bundle][:bundle_id]
    product_id = params[:manual_bundle][:product_id]
    if bundle_id.present? && product_id.present?
      yavolo_bundle_product = YavoloBundleProduct.find_by(yavolo_bundle_id: bundle_id, product_id: product_id)
      yavolo_bundle_product.destroy if yavolo_bundle_product.present?
    end
    render json: {message: "Product removed successfully"}, status: :ok
  end

  def delete_yavolo
    if params[:ids].present?
      @yavolo_bundle_ids = params[:ids].split(',')
      @yavolo_bundles = YavoloBundle.find(@yavolo_bundle_ids)
      YavoloBundle.where(id: @yavolo_bundle_ids).destroy_all
      flash[:notice] = @yavolo_bundle_ids.length > 1 ? 'Yavolo Bundles deleted successfully!' : 'Yavolo Bundle deleted successfully!'
    end
  end

  def bulk_max_stock_limit_value; end

  def bulk_update_max_stock_limit
    if bulk_max_stock_limit_update[:selected_yovolos].present? && bulk_max_stock_limit_update[:max_stock_value].present?
      @yavolo_bundle_ids = bulk_max_stock_limit_update[:selected_yovolos].split(',')
      @yavolo_bundles = YavoloBundle.find(@yavolo_bundle_ids)
      YavoloBundle.where(id: @yavolo_bundle_ids).update(max_stock_limit: bulk_max_stock_limit_update[:max_stock_value].to_i)
      redirect_to admin_yavolos_manual_bundles_path, notice: "Yavolo Bundles updated successfully!"
    end
  end

  def publish_yavolo
    if params[:ids].present?
      @yavolo_bundle_ids = params[:ids].split(',')
      @yavolo_bundles = YavoloBundle.find(@yavolo_bundle_ids)
      number = YavoloBundle.where(id: @yavolo_bundle_ids, status: :draft).update_all(status: :live)
      redirect_to admin_yavolos_manual_bundles_path, notice: "#{number} out of #{@yavolo_bundle_ids.length} yavolos are published"
    end
  end

  private

  def update_associated_products
    @featured_images = []
    params[:products].each do |p|
      product = Product.find_by(id: p[:id])
      next unless product.present?
      @products << product
      product.update(associated_products_params(p))
      @featured_images << product.get_featured_image
    end
  end

  def assign_correct_status_to_bundle
    if params[:commit] == 'APPROVE & PUBLISH'
      @yavolo_bundle.status = 'live'
    elsif params[:commit] == 'SAVE DRAFT'
      @yavolo_bundle.status = 'draft'
    end
  end

  def images_to_delete_params
    @images_to_remove ||= params[:yavolo_bundle][:images_attributes].values.select{|h| h["_destroy"]=="1" } if params[:yavolo_bundle][:images_attributes].present?
  end

  def save_product_images_from_remote_urls(yavolo)
    if params[:yavolo_bundle][:copy_images].present?
      images_urls = params[:yavolo_bundle][:copy_images].map{ |e|
        if Rails.env.production?
          {remote_name_url: "#{e[:remote_name_url]}"}
        else
          {remote_name_url: "#{ENV['HOST_URL']}#{e[:remote_name_url]}"}
        end
      }
      yavolo.pictures_attributes=images_urls
      yavolo.save
    end
  end

  def yavolo_params_for_new
    params.require(:yavolo).permit(:stock_limit, :max_stock_limit, :regular_total, :yavolo_total, :price)
  end

  def manual_bundle_params
    params.require(:yavolo_bundle).permit(:title, :category_id, :description, :price, :quantity, :stock_limit, :max_stock_limit, :regular_total, :yavolo_total,
                                          seo_content_attributes: [:id, :title, :url, :description, :keywords],
                                          google_shopping_attributes: [:id, :title, :price, :category, :campaign_category, :description, :exclude_from_google_feed],
                                          yavolo_bundle_products_attributes: [:id, :product_id, :price],
                                          pictures_attributes: ["name", "@original_filename", "@content_type", "@headers", [:remote_name_url] ],
                                          main_image_attributes: ["name", "@original_filename", "@content_type", "@headers" ]
    )
  end

  def associated_products_params(product_param)
    format_keyword_params(product_param)
    product_param.permit(:id, :title, :keywords, :description)
  end

  def format_price_params
    [:yavolo,:yavolo_bundle].each do |sym|
      next unless params[sym].present?
      [:regular_total, :yavolo_total, :price].each do |key|
        p = view_context.strip_currency_from_price(params[sym][key]) if params[sym][key].present?
        params[sym][key] = p if p.present?
      end
    end
  end

  def format_keyword_params(product_param)
    product_param[:keywords] = Array.wrap(product_param[:keywords]).flatten.reject { |k| k.blank? }.compact.uniq.join(",")
  end

  def bulk_max_stock_limit_update
    params.require(:yavolo_max_stock_limit_update).permit(:max_stock_value, :selected_yovolos)
  end


end
