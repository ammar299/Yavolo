class Admin::CategoriesController < Admin::BaseController
  include CategoryMethods
  before_action :set_category, only: %i[edit update destroy category_details remove_filter_group_association remove_image add_filter_group_association category_products_delete_multiple category_products_with_pagination]

  def index
    @categories = Category.all
    @selected_cat_id = flash[:selected_cat_id].to_i if flash[:selected_cat_id].present?
  end

  def new
    @category = Category.new
    @is_subcategory = params[:is_subcategory] if params[:is_subcategory].present?
  end

  def create
    @category = Category.new(category_params)
    if @category.save
      if params[:selected_cat_id].present?
        flash[:selected_cat_id] = params[:selected_cat_id]
        if params[:is_subcategory].present? # If its assigned as subcategory
          parent = Category.find(params[:selected_cat_id].to_i)
        else # If its assigned as sibling
          parent = Category.find(params[:selected_cat_id].to_i).parent
        end
        @category.parent = parent
        if @category.save
          flash[:notice] = "Category has been saved"
        end
      end
    end
  end

  def update
    @category.update(category_params)
    if @category.baby_category?
      flash[:notice] = "Category has been updated"
      @category.descendants.map(&:destroy)
    end
  end

  def destroy
    @category.destroy
    redirect_to admin_categories_path, notice: "Category has been deleted"
  end

  def category_details
    @category_products = category_products
    render partial: "admin/categories/category_details"
  end

  def category_products_with_pagination
    @category_products = category_products
  end

  def remove_filter_group_association
    @filter_group = FilterGroup.find(params[:filter_group_id])
    if @filter_group.global?
      @category.category_excluded_filter_groups.create(filter_group: @filter_group)
    else
      @category.filter_categories.where(filter_group: @filter_group).first&.destroy
    end
  end

  def add_filter_group_association
    @filter_group = FilterGroup.find_by(id: params[:filter_group_id])
    @association_present = @category.filter_categories.where(filter_group: @filter_group).present?
    if @filter_group.present? && @association_present == false
      @category.filter_categories.create(filter_group: @filter_group)
    end
  end

  def remove_image
    @category.picture.destroy
  end

  def category_products_delete_multiple
    @category.assigned_categories.where(product_id: params['product_ids'].split(',')).destroy_all
    @category_products = category_products
  end

  def manage_category_linking_filter
    category = Category.find(params[:category_id])
    if category.linking_filter.present?
      category.linking_filter.update(filter_in_category_id: params[:filter_in_category_id])
    else
      category.create_linking_filter(filter_in_category_id: params[:filter_in_category_id])
    end
    flash.now[:notice] = 'Linking filter has been updated successfully!'
  end

  private

  def category_params
    params.require(:category).permit(:category_name, :baby_category, :category_description, :bundle_label, picture_attributes: ["name", "@original_filename", "@content_type", "@headers", "_destroy", "id"], meta_content_attributes: [:id, :title, :description, :keywords])
  end

  def set_category
    @category = Category.find(params[:id])
  end

  def category_products
    products = @category.products
    products = products.where('lower(products.title) ilike ?', "%#{params[:q].downcase}%") if params[:q].present?
    products.page(params[:page]).per(params[:per_page].presence || 15)
  end

end
