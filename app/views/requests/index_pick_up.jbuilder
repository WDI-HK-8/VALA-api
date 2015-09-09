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
  json.source_location do
    json.address          request.source_location.address
    json.coordinates      request.source_location.coordinates
  end
end
