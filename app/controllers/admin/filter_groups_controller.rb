class Admin::FilterGroupsController < Admin::BaseController
  before_action :set_filter_group, only: [:show, :edit, :update, :destroy, :confirm_delete]

  def index
    @filter_group_count = FilterGroup.count
    case params.present?
    when params[:filter_type].present?  then @filter_groups =  FilterGroup.where(filter_group_type: params[:filter_type].to_i).includes(:filter_categories, :filter_in_categories).page(params[:page]).per(params[:per_page].presence || 15)
    when params[:search].present?       then @filter_groups = FilterGroup.includes(:filter_categories, :filter_in_categories).search_by_name(params[:search]).page(params[:page]).per(params[:per_page].presence || 15)
    else @filter_groups = FilterGroup.includes(:filter_categories, :filter_in_categories).page(params[:page]).per(params[:per_page].presence || 15)
    end
  end

  def new
    @filter_group = FilterGroup.new
    @filter_group.filter_categories.new
    @filter_group.filter_in_categories.new
  end

  def create
    params[:filter_group][:filter_group_type] =  params[:filter_group][:filter_group_type].to_i
    @filter_group = FilterGroup.new(filter_group_params)
    if @filter_group.save
      redirect_to admin_filter_groups_path
    else
      redirect_to new_admin_filter_groups_path
    end
  end

  def show
  end

  def update
    params[:filter_group][:filter_group_type] =  params[:filter_group][:filter_group_type].to_i
    if @filter_group.update(filter_group_params)
      redirect_to admin_filter_groups_path
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

  def assign_category
    
  end

  def delete_filter_groups
    FilterGroup.where(id: params['ids'].split(',')).destroy_all
    redirect_to admin_filter_groups_path
  end

  private

  def set_filter_group
    @filter_group = FilterGroup.find(params[:id])
  end

  def filter_group_params
    params.require(:filter_group).permit(:name, :filter_group_type, filter_group_ids: [], filter_categories_attributes: [:id, :category_id, :filter_group_id, :_destroy], filter_in_categories_attributes: [:id, :filter_name, :sort_order, :filter_group_id, :_destroy])
  end
end
