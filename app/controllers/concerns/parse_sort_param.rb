module ParseSortParam
  extend ActiveSupport::Concern

  private

  def parse_sort_param_to_array
    return unless params[:q].present? && params[:q][:s].present?
    parsed_sort_params = JSON.parse(params[:q][:s].to_s)
    parsed_sort_params = parsed_sort_params.reject { |c| c.empty? }.uniq
    params[:q][:s] = parsed_sort_params
  end
end