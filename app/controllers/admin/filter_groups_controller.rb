class Admin::FilterGroupsController < Admin::BaseController
  before_action :set_filter_group, only: [:show, :edit, :update, :destroy, :confirm_delete, :assign_category]

  def index

    case params.present?
    when params[:filter_type].present?  then @filter_groups =  FilterGroup.where(filter_group_type: params[:filter_type].to_i).includes(:filter_categories, :filter_in_categories)
    when params[:search].present?       then @filter_groups = FilterGroup.includes(:filter_categories, :filter_in_categories).search_by_name(params[:search])
    else @filter_groups = FilterGroup.includes(:filter_categories, :filter_in_categories)
    end
    @filter_group_count = @filter_groups.size
    @filter_groups = @filter_groups.order(created_at: :desc).page(params[:page]).per(params[:per_page].presence || 15)
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
      redirect_to admin_filter_groups_path, flash: { notice: "Filter Group has been saved" }
    else
      redirect_to admin_filter_groups_path, flash: { alert: "Filter Group can't save" }
    end
  end

  def show
  end

  def update
    params[:filter_group][:filter_group_type] =  params[:filter_group][:filter_group_type].to_i
    if @filter_group.update(filter_group_params)
      redirect_to admin_filter_groups_path, flash: { notice: "Filter Group has been updated" }
    else
      redirect_to edit_admin_filter_group_path(@filter_group), flash: { alert: "Filter Group can't update" }
    end
  end

  def edit
    @filter_group = FilterGroup.find(params[:id])
  end

  def destroy
    @filter_group.destroy
    redirect_to admin_filter_groups_path, flash: { alert: "Filter Group has been deleted" }
  end

  def create_assign_category
    @filter_groups = FilterGroup.where(id: params[:filter_group_ids].split(","))
    @categories = Category.where(id: params[:category])
    @filter_groups.each do |filter_group|
      @categories.each do |category|
        unless filter_group.filter_categories.exists?(category: category)
          filter_group.filter_categories.create(category: category)
        end
      end
    end
    redirect_to admin_filter_groups_path, flash: { notice: "Categories has been assigned" }
  end

  def assign_category
    @filter_group_ids = params[:id]
  end

  def delete_filter_groups
    FilterGroup.where(id: params['ids'].split(',')).destroy_all
    redirect_to admin_filter_groups_path, flash: { alert: "Filter Group has been deleted" }
  end

  private

  def set_filter_group
    @filter_group = FilterGroup.find(params[:id])
  end

  def filter_group_params
    params.require(:filter_group).permit(:name, :filter_group_type, filter_group_ids: [], filter_categories_attributes: [:id, :category_id, :filter_group_id, :_destroy], filter_in_categories_attributes: [:id, :filter_name, :sort_order, :category_id, :filter_group_id, :_destroy])
  end
end
