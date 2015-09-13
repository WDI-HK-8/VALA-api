class StaticPagesController < ApplicationController
  def user_location

  end

  def valet_location
    
  end

  private
    def location_params
      params.require(:location).permit(:latitude,:longitude)
    end
end
