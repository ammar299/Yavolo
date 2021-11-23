class Buyers::BaseController < ApplicationController
  before_action :authenticate_buyer!
  # layout 'buyers/buyer'
  layout 'buyers/checkout/buyer_checkout'
end
