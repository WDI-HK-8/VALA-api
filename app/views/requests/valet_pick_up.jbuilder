json.request_id               @request.id
json.valet_id_pick_up @request.valet_pick_up.id
json.user do
  json.id             @request.user.id
  json.name           "#{@request.user.first_name} #{@request.user.last_name}"
  json.phone_number   @request.user.phone_number
  json.car do
    json.picture      @request.user.car_picture
    json.color        @request.user.car_color
    json.make         @request.user.car_make
    json.license_plate @request.user.car_license_plate
    if @request.user.is_manual? 
      transmission = "Manual"
    else 
      transmission = "Automatic"
    end
    json.transmission transmission
  end
end
json.source_location do
  json.address        @request.source_location.address
  json.latitude       @request.source_location.latitude
  json.longitude      @request.source_location.longitude
end
json.parking_location do
  json.address        @request.parking_location.address
  json.latitude       @request.parking_location.latitude
  json.longitude      @request.parking_location.longitude
end
json.auth_code        @request.auth_code_pick_up
