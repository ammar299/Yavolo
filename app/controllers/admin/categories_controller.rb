class Admin::CategoriesController < Admin::BaseController

  before_action :set_category, only: %i[edit update destroy]

  def index
    @categories = Category.all
  end

  def new
    @category = Category.new
    @parent_id = params[:parent_id] if params[:parent_id].present?
  end

  def create
    @category = Category.new(category_params)
    if @category.save
      if params[:parent_id].present?
        parent = Category.find(params[:parent_id].to_i)
        @category.parent = parent
        @category.save
      end
      redirect_to admin_categories_path, notice: "Category is Created"
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

  private

  def category_params
    params.require(:category).permit(:category_id, :baby_category, :category_description,bundle_label: [])
  end

  def set_category
    @category = Category.find(params[:id])
  end

end