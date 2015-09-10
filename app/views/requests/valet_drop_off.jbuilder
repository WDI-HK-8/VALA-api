json.request_id   @request.id

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

json.parking_location do
  json.address        @request.parking_location.address
  json.latitude       @request.parking_location.latitude
  json.longitude      @request.parking_location.longitude
  json.bay_number     @request.bay_number
end

json.destination_location do
  json.address        @request.destination_location.address
  json.latitude       @request.destination_location.latitude
  json.longitude      @request.destination_location.longitude
end