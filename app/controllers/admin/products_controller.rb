class Admin::ProductsController < Admin::BaseController
  def index
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
    respond_to do |format|
      if @product.save
        format.html { redirect_to admin_products_path, notice: 'Product was successfully created.' }
      else
        format.html { render action: 'new' }
      end
    end
  end

  def edit
  end

  def update
  end

  private
    def product_params
      params.require(:product).permit(pictures_attributes: ["name", "@original_filename", "@content_type", "@headers", "_destroy", "id"])
    end

    def owner_params
      { owner_id: current_admin.id, owner_type: 'Admin' }
    end
end
