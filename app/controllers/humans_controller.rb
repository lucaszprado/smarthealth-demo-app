# app/controllers/humans_controller.rb
class HumansController < ApplicationController
  def show
    @human = Human.find(params[:id])
    
  end
end
