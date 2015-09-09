json.id           @request.id
json.user_id      @request.user.id
json.source_location do
  json.address     @request.source_location.address
  json.coordinates @request.source_location.coordinates
end
json.status       @request.status