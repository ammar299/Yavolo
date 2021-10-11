class Buyers::BaseController < ApplicationController
  before_action :authenticate_buyer!
  layout 'buyers/buyer'
end
