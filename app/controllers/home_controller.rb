class HomeController < ApplicationController

  def test 
    render json: {data: 'ssss'}
  end
end