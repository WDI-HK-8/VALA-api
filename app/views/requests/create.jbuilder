json.id           @request.id
json.user_id      @request.user.id
json.source_location do
  json.address     @request.source_location.address
  json.latitude    @request.source_location.latitude
  json.longitude   @request.source_location.longitude
end
json.status       @request.status
