class Admin::Yavolos::ManualBundlesController < Admin::BaseController

  def index
  end

  def new
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


end
