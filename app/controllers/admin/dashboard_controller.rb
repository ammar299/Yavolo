class Admin::DashboardController < ApplicationController
    before_action :authenticate_admin!
    layout "admin/admin"

    def index; end
end