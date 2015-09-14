require 'private_pub'
PrivatePub.load_config(File.expand_path("../../../config/private_pub.yml", __FILE__), ENV["RAILS_ENV"] || "development")
class RequestsController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found
  rescue_from AASM::InvalidTransition, :with => :invalid_state

  def index
    @requests = Request.all
  end

  def create
    #create location entered
    user = User.find(params[:user_id])
    new_location = Location.new(longitude: request_create_params[:longitude], latitude: request_create_params[:latitude])
    if new_location.save
      @request = user.requests.new(source_location: new_location)
      if @request.save
        request =  {
          id:             @request.id,
          name:           "#{@request.user.first_name} #{@request.user.last_name}",
          picture:        @request.user.profile_picture,
          transmission:   @request.user.is_manual,
          phone:          @request.user.phone_number,
          latitude:       @request.source_location.latitude,
          longitude:      @request.source_location.longitude,
          location:       @request.source_location.address,
          type:           "pick_up"
        }
        PrivatePub.publish_to "/valet/new", :request => request
      else
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

  #search for requesting dropoff
  def index_drop_off
    @requests = Request.where(status: "request_drop_off")
  end

  #valet puts their id into the request
  def valet_pick_up
    @request = Request.find(params[:request_id])
    if @request.valet_pick_up.nil?
      @request.update(valet_pick_up: Valet.find(params[:valet_id]))
      @request.pick_up_retrieved!
      # Generate authentication code
      @request.generate_auth_code("pick_up")
      # find the nearest parking lot
      @request.find_nearest_parking
      pick_up_valet = {
        id:       @request.id,
        valet_id: @request.valet_pick_up.id,
        name:     "#{@request.valet_pick_up.first_name} #{@request.valet_pick_up.last_name}",
        picture:  @request.valet_pick_up.profile_picture,
        phone:    @request.valet_pick_up.phone_number
      }
      PrivatePub.publish_to "/user/#{@request.id}", :valet => pick_up_valet
    else
      render 'record_already_responded', status: :bad_request
    end
  end

  #user confirms auth code
  def car_pick_up
    @request = User.find(params[:user_id]).requests.find(params[:request_id])
    if @request.auth_code_check?(request_auth_code_params[:auth_code], "pick_up")
      @request.record_time("pick_up")
      @request.auth_code_matched_pick_up!
    else
      render json: {error: "Incorrect auth code"}, status: :bad_request
    end
  end

  #valet has parked the car
  def car_parked
    @request = Request.find_by!('valet_pick_up_id = ? AND id = ?', Valet.find(params[:valet_id]).id, params[:request_id])
    @request.update(bay_number: valet_car_parked_params[:bay_number])
    @request.keys_dropped!
    parking_spot = {
      latitude:   @request.parking_location.latitude,
      longitude:  @request.parking_location.longitude,
      address:    @request.parking_location.address
    }
    PrivatePub.publish_to "/user/#{@request.id}", :parking_spot => parking_spot 
    render 'okay'
  end

  #user requests drop off
  def request_drop_off
    @request = User.find(params[:user_id]).requests.find(params[:request_id])
    @request.drop_off_requested!
    destination_location = Location.new(latitude: request_create_params[:latitude], longitude: request_create_params[:longitude])
    @request.update(destination_location: destination_location)
    @request.record_time
    @request.calculate_total
    request_information = {
      id:                         @request.id,
      name:                       "#{@request.user.first_name} #{@request.user.last_name}",
      picture:                    @request.user.profile_picture,
      transmission:               @request.user.is_manual,
      phone:                      @request.user.phone_number,
      destination_latitude:       @request.destination_location.latitude,
      destination_longitude:      @request.destination_location.longitude,
      destination_location:       @request.destination_location.address,
      parking_location_latitude:  @request.parking_location.latitude,
      parking_location_longitude: @request.parking_location.longitude,
      parking_location_location:  @request.parking_location.address,
      type:                       "drop_off"
    }
    PrivatePub.publish_to "/valet/new", :valet => request_information
  end
  #valet accepts drop off
  def valet_drop_off
    @request = Request.find(params[:request_id])
    @request.drop_off_retrieved!
    @request.update(valet_drop_off: Valet.find(params[:valet_id]))
    @request.calculate_total
    valet_information = {
      id:       @request.id,
      valet_id: @request.valet_drop_off.id,
      name:     "#{@request.valet_drop_off.first_name} #{@request.valet_drop_off.last_name}",
      picture:  @request.valet_drop_off.profile_picture,
      phone:    @request.valet_drop_off.phone_number
    }
    PrivatePub.publish_to "/user/#{@request.id}", :valet => valet_information
  end

  #valet has arrived at the car
  def valet_delivery
    @request = Request.find_by!('valet_drop_off_id = ? AND id = ?', Valet.find(params[:valet_id]), params[:request_id])
    @request.generate_auth_code
    @request.valet_on_route_drop_off!
    PrivatePub.publish_to "/user/#{@request.id}", :status => @request.status
  end

  #user keys in auth code
  def car_drop_off
    @request = User.find(params[:user_id]).requests.find(params[:request_id])
    if @request.auth_code_check?(request_auth_code_params[:auth_code])
      @request.auth_code_matched_drop_off!
      PrivatePub.publish_to "/valet/#{@request.id}", :status => @request.status
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
  end

  def cancel_request
    @request = Request.find(params[:id])
    @request.cancel
    render "okay"
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
