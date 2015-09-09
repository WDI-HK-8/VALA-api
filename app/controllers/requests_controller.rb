class RequestsController < ApplicationController
  def create
    #create location entered
    user_id = params[:user_id]
    begin
      user = User.find(user_id)
      request_params = request_create_params
      location = request_params[:source_location].split(',')
      new_location = Location.new({coordinates:[ location[0], location[1]]})
      if new_location.save
        # save successfuly, create the request
        request_params[:source_location] = new_location
        #find user

          request = user.requests.create(request_params)
      else
        # location not save
        render json: {error: "Location not saved"}, status: :bad_request
      end
    rescue ActiveRecord::RecordNotFound 
        render json: {error: "User does not exist"}, status: :bad_request
    end
  end


  private
    def request_create_params
      params.require(:request).permit(:source_location, :user_id)
    end
end
