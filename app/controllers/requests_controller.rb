class RequestsController < ApplicationController
  def create
    #create location entered
    request_params = request_create_params
    location = request_params[:source_location].split(',')
    new_location = Location.new({coordinates:[ location[0], location[1]]})
    if new_location.save
      # save successfuly, create the request
      request_params[:source_location] = new_location
      request = Request.create(request_params)
    else
      # location not save
      render json: {error: "Location not saved"}, status: :bad_request
    end
  end


  private
    def request_create_params
      params.require(:request).permit(:source_location, :user_id)
    end
end
