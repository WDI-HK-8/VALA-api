json.array! @valets do |valet|
  json.id                   valet.id
  json.picture              valet.profile_picture
  json.first_name           valet.first_name
  json.last_name            valet.last_name
  json.email                valet.email
  json.phone_number         valet.phone_number
  json.manual               valet.manual
  json.status               valet.status
  json.years_of_driving     valet.years_of_driving
  json.updated_at           valet.updated_at
end
