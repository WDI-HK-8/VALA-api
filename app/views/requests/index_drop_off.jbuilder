json.array! @requests do |request|
  json.id       request.id
  json.user do
    json.id               request.user.id
    json.name             "#{request.user.first_name} #{request.user.last_name}"
    json.profile_picture  request.user.profile_picture
    if request.user.is_manual
      transmission = "manual"
    else
      transmission = "automatic"
    end
    json.transmission     transmission
    json.phone_number     request.user.phone_number
  end
  json.parking_location do
    json.address          request.parking_location.address
    json.latitude         request.parking_location.latitude
    json.longitude        request.parking_location.longitude 
  end
  json.destination_location do
    json.address          request.destination_location.address
    json.latitude         request.destination_location.latitude
    json.longitude        request.destination_location.longitude 
  end
end
