module Admin::AdminHelper

  def admin_name(current_admin)
    current_admin.try(:first_name).to_s + " " + current_admin.try(:last_name).to_s
  end

  def print_filter_by_status_tags
    return if params[:statuses].blank? && params[:yavolo_enabled].blank?
    tags_template = []
    params[:statuses].split(',').each do |status|
      tags_template << "<div class='mr-2 filter-tag'>#{status.titleize}<span data-yfilter=\"#{status}\"  class=\"rm-filterby icon-cross\"></span></div>"
    end if params[:statuses].present?
    tags_template << "<div class='mr-2 filter-tag'>Yavolo Enabled<span data-yfilter='yavolo_enabled'  class='rm-filterby icon-cross'></span></div>" if params[:yavolo_enabled].present?
    tags_template.join('')
  end

  def print_filter_by_sort_tags
    return unless params[:q].present? && params[:q][:s].present?
    tags_template = []
    params[:q][:s].each do |status|
      tags_template << "<div class='mr-2 filter-tag'>#{sort_filter_tags_titles(status)}<span data-yfilter=\"#{status}\"  class=\"rm-filterby icon-cross\"></span></div>"
    end
    tags_template.join('')
  end

  def sort_filter_tags_titles(status)
    case status.titleize
    when "Title Asc"
      "Product Title A-Z"
    when "Title Desc"
      "Product Title Z-A"
    when "Price Desc"
      "Price High-Low"
    when "Price Asc"
      "Price Low-High"
    end
  end

  def admin_heading(params)
    params[:controller] == 'admin/dashboard' && params[:action] == 'index'
  end

end
