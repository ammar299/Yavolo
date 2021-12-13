class Admin::Yavolos::ManualBundlesController < Admin::BaseController

  before_action :format_price_params, only: [:new]

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

  def create_bundle
    @yavolo_bundle = YavoloBundle.new(manual_bundle_params)
    @products = []
    params[:products].each do |p|
      product = Product.find_by(id: p[:id])
      next unless product.present?
      @products << product
      product.update(associated_products_params(p))
    end
    if params[:commit]== 'APPROVE & PUBLISH'
      @yavolo_bundle.status = 'live'
    elsif params[:commit]== 'SAVE DRAFT'
      @yavolo_bundle.status = 'draft'
    end
    # TODO: Update products
    if @yavolo_bundle.save
      redirect_to admin_yavolos_manual_bundles_path, notice: "Bundle created successfully"
    else
      render :new
    end
  end

  def add_yavolos
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

  private

  def yavolo_params_for_new
    params.require(:yavolo).permit(:stock_limit, :max_stock_limit, :regular_total, :yavolo_total, :price)
  end

  def manual_bundle_params
    params.require(:yavolo_bundle).permit(:title,:category_id,:description,:price, :quantity, :stock_limit, :max_stock_limit, :regular_total, :yavolo_total,
                                          seo_content_attributes: [:id,:title, :url, :description, :keywords],
                                          google_shopping_attributes: [:id,:title,:price,:category,:campaign_category,:description,:exclude_from_google_feed],
                                          yavolo_bundle_products_attributes: [:id,:product_id, :price]
                                          )
  end

  def associated_products_params(product_param)
    format_keyword_params(product_param)
    product_param.permit(:id, :title, :keywords, :description)
  end

  def format_price_params
    return unless params[:yavolo].present?
    [:regular_total,:yavolo_total,:price].each do |key|
      p = view_context.strip_currency_from_price(params[:yavolo][key]) if params[:yavolo][key].present?
      params[:yavolo][key] = p if p.present?
    end
  end

  def format_keyword_params(product_param)
    product_param[:keywords] = product_param[:keywords].reject {|k| k.blank?}.compact.uniq.join(",")
  end


end
