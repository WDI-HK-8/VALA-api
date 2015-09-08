class Location < ActiveRecord::Base
  has_many :requests
end
