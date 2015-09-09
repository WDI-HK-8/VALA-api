class Request < ActiveRecord::Base
  belongs_to :user
  belongs_to :valet_pick_up, class_name: "Valet"
  belongs_to :valet_drop_off, class_name: "Valet"
  belongs_to :source_location, class_name: "Location"
  belongs_to :parking_location, class_name: "Location"
  belongs_to :destination_location, class_name: "Location"
end
