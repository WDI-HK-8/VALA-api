class RequestsController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found
  
  def index
    @requests = Request.all
  end

  def create
    #create location entered
    user_id = params[:user_id]
    user = User.find(user_id)
    request_params = request_create_params
    new_location = Location.new(longitude: request_params[:longitude], latitude: request_params[:latitude])
    if new_location.save
      # save successfuly, create the request
      request_hash = Hash.new
      request_hash[:source_location] = new_location
      @request = user.requests.new(request_hash)
      unless @request.save 
        render json: {error: "Request not saved"}, status: :bad_request
      end
    else
      # location not save
      render json: {error: "Location not saved"}, status: :bad_request
    end
  end

  def index_pick_up
    @requests = Request.where(status: "request_pick_up")
  end

  def valet_pick_up
    valet = Valet.find(params[:valet_id])
    @request = Request.find(params[:id])
    if @request.valet_pick_up.nil?
      @request.update(valet_pick_up: valet)
      @request.pick_up_retrieved!
      # Generate authentication code
      @request.generate_auth_code
      # find the nearest parking lot
      @request.find_nearest_parking
    else
      render 'record_already_responded', status: :bad_request
    end
  end

  private
    def request_create_params
      params.require(:request).permit(:latitude,:longitude)
    end
    def record_not_found
      render 'record_not_found', status: :bad_request
    end
end
