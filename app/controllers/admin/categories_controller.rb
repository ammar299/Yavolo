class Admin::CategoriesController < Admin::BaseController

  before_action :set_category, only: %i[edit update destroy]

  def index
    @categories = Category.all
    @category = Category.first
  end

  def new
    @category = Category.new
    @selected_cat_id = params[:selected_cat_id] if params[:selected_cat_id].present?
    @is_subcategory = params[:is_subcategory] if params[:selected_cat_id].present?
  end

  def create
    @category = Category.new(category_params)
    if @category.save
      if params[:selected_cat_id].present?
        if params[:is_subcategory].present? # If its assigned as subcategory
          parent = Category.find(params[:selected_cat_id].to_i)
        else # If its assigned as sibling
          parent = Category.find(params[:selected_cat_id].to_i).parent
        end
        @category.parent = parent
        @category.save
      end
      redirect_to admin_categories_path
    else
      render :new
    end
  end

  def update
    if @category.update(category_params)
      redirect_to admin_categories_path, notice: "Category is updated"
    else
      render :edit
    end
  end

  def destroy
    @category.destroy
    redirect_to admin_categories_path, notice: "Category is destroyed"
  end

  def category_details
    @category = Category.find(params[:id])
    render partial:"admin/categories/category_details"
  end

  private

  def category_params
    params.require(:category).permit(:category_name, :baby_category, :category_description,:bundle_label, picture_attributes: ["name", "@original_filename", "@content_type", "@headers", "_destroy", "id"])
  end

  def set_category
    @category = Category.find(params[:id])
  end

end
