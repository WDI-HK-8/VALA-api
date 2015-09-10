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

  #search for requesting pickup
  def index_pick_up
    @requests = Request.where(status: "request_pick_up")
  end

  #valet puts their id into the request
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

  #user confirms auth code
  def car_pick_up
    @request = User.find(params[:user_id]).requests.find(params[:id])
    auth_code = request_auth_code_params[:auth_code]
    if @request.auth_code_check?(auth_code)
      @request.record_time
      @request.auth_code_matched_pick_up!
    else
      render json: {error: "Incorrect auth code"}, status: :bad_request
    end
  end

  #valet has parked the car
  def car_parked
    valet = Valet.find(params[:valet_id])
    bay_number = valet_car_parked_params[:bay_number]
    @request = Request.find_by!('valet_pick_up_id = ? AND id = ?', valet.id, params[:id])
    @request.update(bay_number: bay_number)
    @request.keys_dropped!
    render json: {}, status: :no_content
  end
 
  def request_drop_off
    @request = User.find(params[:user_id]).requests.find(params[:id])
    destination = request_create_params
    @request.drop_off_requested
    destination_location = Location.new(latitude: destination[:latitude], longitude: destination[:longitude])
    @request.update(destination_location: destination_location)
    @request.record_time(true)
  end

  private
    def request_create_params
      params.require(:request).permit(:latitude,:longitude)
    end

    def request_auth_code_params
      params.require(:request).permit(:auth_code)
    end

    def valet_car_parked_params
      params.require(:request).permit(:bay_number)
    end

    def record_not_found
      render 'record_not_found', status: :bad_request
    end
end
