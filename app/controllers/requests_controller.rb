class RequestsController < ApplicationController
  def create
    #create location entered
    user_id = params[:user_id]
    begin
      user = User.find(user_id)
      request_params = request_create_params
      location = request_params[:source_location].split(',')
      new_location = Location.new({coordinates:[ location[0], location[1]], address: request_params[:address], category: "Random"})
      if new_location.save
        # save successfuly, create the request
        request_hash = Hash.new
        request_hash[:source_location] = new_location
        @request = user.requests.create(request_hash)
      else
        # location not save
        render json: {error: "Location not saved"}, status: :bad_request
      end
    rescue ActiveRecord::RecordNotFound 
        render json: {error: "User does not exist"}, status: :bad_request
    end
  end

  def index_pick_up
    @requests = Request.where(status: "request_pick_up")
  end

  private
    def request_create_params
      params.require(:request).permit(:source_location, :address)
    end
end
