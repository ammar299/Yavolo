class Buyers::DashboardController < Buyers::BaseController
    skip_before_action :authenticate_buyer!, only: [:index]
    def index; end
    layout 'buyers/buyer'
end
