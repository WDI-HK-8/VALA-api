class RequestsController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found
  rescue_from AASM::InvalidTransition, :with => :invalid_state

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
      #PRIVATE PUB publish to all valets. 
      unless @request.save 
        render json: {error: "Request not saved"}, status: :bad_request
      end
      PrivatePub.publish_to "/valet/new", :request => {id: @request.id,
                                                      name: "#{@request.user.first_name} #{@request.user.last_name}",
                                                      picture: @request.user.profile_picture,
                                                      transmission: @request.user.is_manual,
                                                      phone: @request.user.phone_number,
                                                      latitude: @request.source_location.latitude,
                                                      longitude: @request.source_location.longitude,
                                                      location: @request.source_location.address,
                                                      type: "pick_up"
                                                    }
    else
      # location not save
      render json: {error: "Location not saved"}, status: :bad_request
    end
  end

  #search for requesting pickup
  def index_pick_up
    @requests = Request.where(status: "request_pick_up")
  end

    #search for requesting dropoff
  def index_drop_off
    @requests = Request.where(status: "request_drop_off")
  end  


  #valet puts their id into the request
  def valet_pick_up
    valet = Valet.find(params[:valet_id])
    @request = Request.find(params[:request_id])
    if @request.valet_pick_up.nil?
      @request.update(valet_pick_up: valet)
      @request.pick_up_retrieved!
      # Generate authentication code
      @request.generate_auth_code("pick_up")
      # find the nearest parking lot
      @request.find_nearest_parking
      PrivatePub.publish_to "/user/#{@request.id}", :chat_message => @request.valet_pick_up
    else
      render 'record_already_responded', status: :bad_request
    end
  end

  #user confirms auth code
  def car_pick_up
    @request = User.find(params[:user_id]).requests.find(params[:request_id])
    auth_code = request_auth_code_params[:auth_code]
    if @request.auth_code_check?(auth_code, "pick_up")
      @request.record_time("pick_up")
      @request.auth_code_matched_pick_up!
      PrivatePub.publish_to "valet/#{@request.id}", :chat_message => @request.status
    else
      render json: {error: "Incorrect auth code"}, status: :bad_request
    end
  end

  #valet has parked the car
  def car_parked
    valet = Valet.find(params[:valet_id])
    bay_number = valet_car_parked_params[:bay_number]
    @request = Request.find_by!('valet_pick_up_id = ? AND id = ?', valet.id, params[:request_id])
    @request.update(bay_number: bay_number)
    @request.keys_dropped!
    PrivatePub.publish_to "user/#{@request.id}", :chat_message => @request.status
    render 'okay'
  end
  
  #user requests drop off
  def request_drop_off
    @request = User.find(params[:user_id]).requests.find(params[:request_id])
    destination = request_create_params
    @request.drop_off_requested!
    destination_location = Location.new(latitude: destination[:latitude], longitude: destination[:longitude])
    @request.update(destination_location: destination_location)
    @request.record_time
    @request.calculate_total
    PrivatePub.publish_to "/valet/new", :request => {id: @request.id,
                                                name: "#{@request.user.first_name} #{@request.user.last_name}",
                                                picture: @request.user.profile_picture,
                                                transmission: @request.user.is_manual,
                                                phone: @request.user.phone_number,
                                                latitude: @request.destination_location.latitude,
                                                longitude: @request.destination_location.longitude,
                                                location: @request.destination_location.address,
                                                type: "drop_off"
                                              }
  end
  #valet accepts drop off
  def valet_drop_off
    valet = Valet.find(params[:valet_id])
    @request = Request.find(params[:request_id])
    @request.drop_off_retrieved!
    @request.update(valet_drop_off: valet)
    @request.calculate_total
  end

  #valet has arrived at the car
  def valet_delivery
    valet = Valet.find(params[:valet_id])
    @request = Request.find_by!('valet_drop_off_id = ? AND id = ?', valet.id, params[:request_id])
    @request.generate_auth_code
    @request.valet_on_route_drop_off!
    PrivatePub.publish_to "user/#{@request.id}", :chat_message => @request.status
  end

  #user keys in auth code
  def car_drop_off
    @request = User.find(params[:user_id]).requests.find(params[:request_id])
    auth_code = request_auth_code_params[:auth_code]
    if @request.auth_code_check?(auth_code)
      @request.auth_code_matched_drop_off!
      PrivatePub.publish_to "valet/#{@request.id}", :chat_message => @request.status
      render 'okay'
    else
      render json: {error: "Incorrect auth code"}, status: :bad_request      
    end
  end

  def ratings
    @request = User.find(params[:user_id]).requests.find(params[:request_id])
    ratings = rating_params
    @request.update(tip: ratings[:tip], rating_pick_up: ratings[:pick_up], rating_drop_off: ratings[:drop_off])
    @request.rating_complete!
    PrivatePub.publish_to "valet/#{@request.id}", :chat_message => @request.status
  end

  def cancel_request
    @request = Request.find(params[:id])
    @request.cancel
    render "okay"
    PrivatePub.publish_to "valet/#{@request.id}", :chat_message => @request.status
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

    def rating_params
      params.require(:request).permit(:pick_up, :drop_off, :tip)
    end

    def record_not_found
      render 'record_not_found', status: :bad_request
    end

    def invalid_state
      render 'invalid_state', status: :bad_request
    end
end
