module CategoryMethods
  extend ActiveSupport::Concern

  def search_category
    @categories = Category.where("category_name LIKE ? AND baby_category = ?", "%#{params[:q]}%", true)
    generate_response_for_search_category
  end

  def search_all_categories
    @categories = Category.where("category_name LIKE ? ", "%#{params[:q]}%")
    generate_response_for_search_category
  end

  def get_filter_groups
    @product = Product.where(id: params[:product_id]).first if params[:product_id].present?
    @category = Category.where(id: params[:id]).includes(filter_groups: :filter_in_categories).first
    render "shared/get_filter_groups"
  end

  private

  def generate_response_for_search_category
    @categories = @categories.page(params[:page]).per(params[:per_page].presence || 10)
    render json: {
        categories: @categories.as_json(only: [:id,:category_name]),
        total_count: @categories.total_count
    }, status: :ok
  end
end
