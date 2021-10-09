class Admin::FilterGroupsController < Admin::BaseController
  before_action :set_filter_group, only: [:show, :edit, :update, :destroy]

  def index
    @filter_groups = FilterGroup.includes(:filter_categories, :filter_in_categories)
  end

  def new
    @filter_group = FilterGroup.new
    @filter_group.filter_categories.new
    @filter_group.filter_in_categories.new
  end

  def create
    @filter_group = FilterGroup.new(filter_group_params)
    if @filter_group.save
      redirect_to admin_filter_group_path
    else
      redirect_to new_admin_filter_group_path
    end
  end

  def show
  end

  def update
    if @filter_group.update(filter_group_params)
      redirect_to admin_filter_group_path
    else
      redirect_to edit_admin_filter_group_path(@filter_group)
    end
  end

  def edit
    @filter_group = FilterGroup.find(params[:id])
  end

  def destroy
    @filter_group.destroy
    redirect_to admin_filter_groups_path
  end

  private

  def set_filter_group
    @filter_group = FilterGroup.find(params[:id])
  end

  def filter_group_params
    params.require(:filter_group).permit(:name, :filter_group_type, filter_categories_attributes: [:id, :category_name, :filter_group_id, :_destroy], filter_in_categories_attributes: [:id, :filter_name, :sort_order, :filter_group_id, :_destroy])
  end
end
