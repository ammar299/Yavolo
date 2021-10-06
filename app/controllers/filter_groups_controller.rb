class FilterGroupsController < ApplicationController
  # before_action :set_filter_group

  def index
    @filter_groups = FilterGroup.all
  end

  def new
    @filter_group = FilterGroup.new
  end

  def create
      byebug
    @filter_groups = FilterGroup.new(filter_group_params)
    if @filter_groups.save
    else
    end
  end

  def show;end

  def update

  end

  def edit;end

  private

  def set_filter_group
    @filter_group = FilterGroup.find(params[:id])
  end

  def filter_group_params
    params.require(:filter_group).permit(:name, :filter_type, filter_category_attributes: [:category_name, :filter_group_id], filter_in_category_attributes: [:filter_name, :sort_order, :filter_group_id])
  end
end
