class HomeController < ApplicationController
    skip_before_action :authenticate_user!
    
    def index; end

    def signup; end

    def signin; end
end