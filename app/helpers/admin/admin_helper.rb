module Admin::AdminHelper

  def admin_name(current_admin)
    current_admin.try(:first_name).to_s + " " + current_admin.try(:last_name).to_s
  end

end
