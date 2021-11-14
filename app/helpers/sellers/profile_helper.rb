module Sellers::ProfileHelper
  def return_and_terms_duration
    ReturnAndTerm.durations.map {|k, v| [k.split('_').join(' '), k]}
  end

  def page_base_style
    if params[:id].present?
      {class: 'add_new_seller_profile_form'}
    else
      {id: 'add_new_seller_profile_form'}
    end
  end
end
