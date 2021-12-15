class Admin::Yavolos::ManualBundlesController < Admin::BaseController

  before_action :format_price_params, only: %i[new edit create_bundle update_bundle]

  def index
    @q = YavoloBundle.ransack(params[:q])
    @yavolo_bundles = @q.result(distinct: true)
    @yavolo_bundles = @yavolo_bundles.order(created_at: :desc) if params.dig(:q, :s).blank?
    @total_count = @yavolo_bundles.size
    @yavolo_bundles = @yavolo_bundles.page(params[:page]).per(params[:per_page].presence || 15)
  end

  def new
    @yavolo_bundle = YavoloBundle.new(yavolo_params_for_new)
    @products = []
    params[:products].each do |p|
      product = Product.find_by(id: p[:id])
      next unless product.present?
      @products << product
      @yavolo_bundle.yavolo_bundle_products << YavoloBundleProduct.new(product: product, price: view_context.strip_currency_from_price(p[:discount_price]))
    end
    @yavolo_bundle.build_seo_content
    @yavolo_bundle.build_google_shopping
  end

  def edit
    @yavolo_bundle = YavoloBundle.find_by(id: params[:yavolo_bundle_id])
    if @yavolo_bundle.present?
      @products = []
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
      redirect_to admin_yavolos_manual_bundles_path, notice: "Bundle updated successfully"
    else
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

  def remove_product_bundle_association
    bundle_id = params[:manual_bundle][:bundle_id]
    product_id = params[:manual_bundle][:product_id]
    if bundle_id.present? && product_id.present?
      yavolo_bundle_product = YavoloBundleProduct.find_by(yavolo_bundle_id: bundle_id, product_id: product_id)
      yavolo_bundle_product.destroy if yavolo_bundle_product.present?
    end
    render json: {message: "Product removed successfully"}, status: :ok
  end

  private

  def update_associated_products
    params[:products].each do |p|
      product = Product.find_by(id: p[:id])
      next unless product.present?
      @products << product
      product.update(associated_products_params(p))
    end
  end

  def assign_correct_status_to_bundle
    if params[:commit] == 'APPROVE & PUBLISH'
      @yavolo_bundle.status = 'live'
    elsif params[:commit] == 'SAVE DRAFT'
      @yavolo_bundle.status = 'draft'
    end
  end

  def yavolo_params_for_new
    params.require(:yavolo).permit(:stock_limit, :max_stock_limit, :regular_total, :yavolo_total, :price)
  end

  def manual_bundle_params
    params.require(:yavolo_bundle).permit(:title, :category_id, :description, :price, :quantity, :stock_limit, :max_stock_limit, :regular_total, :yavolo_total,
                                          seo_content_attributes: [:id, :title, :url, :description, :keywords],
                                          google_shopping_attributes: [:id, :title, :price, :category, :campaign_category, :description, :exclude_from_google_feed],
                                          yavolo_bundle_products_attributes: [:id, :product_id, :price]
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


end
