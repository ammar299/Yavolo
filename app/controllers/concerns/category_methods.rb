module CategoryMethods
  extend ActiveSupport::Concern

  def search_category
    @categories = Category.where("category_name LIKE ? AND baby_category = ?", "%#{params[:q]}%", true).limit(10)
    render json: { data: @categories }
  end

  def get_filter_groups
    @product = Product.where(id: params[:product_id]).first if params[:product_id].present?
    @category = Category.where(id: params[:id]).includes(filter_groups: :filter_in_categories).first
    render "shared/get_filter_groups"
  end
end
