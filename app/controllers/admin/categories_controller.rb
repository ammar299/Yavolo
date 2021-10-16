class Admin::CategoriesController < Admin::BaseController

  before_action :set_category, only: %i[edit update destroy category_details remove_filter_group_association remove_image add_filter_group_association]

  def index
    @categories = Category.all
  end

  def new
    @category = Category.new
    @is_subcategory = params[:is_subcategory] if params[:is_subcategory].present?
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
    render partial:"admin/categories/category_details"
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

  private

  def category_params
    params.require(:category).permit(:category_name, :baby_category, :category_description,:bundle_label, picture_attributes: ["name", "@original_filename", "@content_type", "@headers", "_destroy", "id"])
  end

  def set_category
    @category = Category.find(params[:id])
  end

end
