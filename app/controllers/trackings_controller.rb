class StaticPagesController < ApplicationController
  def user_location
    user_id = params[:user_id]
    location = location_params
    PrivatePub.publish_to "/user/location/#{user_id}", :location => location
  end

  def valet_location
    valet_id = params[:valet_id]
    location = location_params
    PrivatePub.publish_to "/valet/location/#{valet_id}", :location => location
  end

  private
    def location_params
      params.require(:location).permit(:latitude,:longitude)
    end
end
