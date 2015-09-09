json.id           @request.id
json.user_id      @request.user.id
json.source_location do
  json.address     @request.source_location.address
end
json.status       @request.status
