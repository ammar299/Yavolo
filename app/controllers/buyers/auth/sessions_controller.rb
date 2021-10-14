# frozen_string_literal: true

class Buyers::Auth::SessionsController < Devise::SessionsController

  def after_sign_in_path_for(resource)
    super(resource)
    buyers_buyer_authenticated_root_path # or whatever path you want here
  end

  def after_sign_out_path_for(resource_or_scope)
    new_buyer_session_path
  end

end
