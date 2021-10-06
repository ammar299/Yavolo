class Admin::SellersController < ApplicationController

    def index
        @sellers = Seller.all
    end

    def edit
        @seller = Seller.find(params[:id])
    end
end
