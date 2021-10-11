class Sellers::BaseController < ApplicationController
  before_action :authenticate_seller!
  layout 'sellers/seller'
end
