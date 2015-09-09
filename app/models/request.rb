class Request < ActiveRecord::Base
  include AASM
  aasm :column => :status do 
    state :request_pick_up, :initial => true
    state :valet_pick_up
    state :car_pick_up
    state :in_transit_pick_up
    state :car_parked
    state :request_drop_off
    state :valet_drop_off
    state :in_transit_drop_off
    state :car_drop_off
    state :rating
    state :completed
    state :cancelled, :before_enter => :remove_valet_pick_up

    event :cancel_pick_up do
      transitions :from => [:request_pick_up, :valet_pick_up], :to => :cancelled
    end

    event :cancel_drop_off do
      transitions :from => [:request_drop_off, :valet_drop_off], :to => :car_parked, :after => :remove_valet_drop_off
    end

    event :pick_up_retrieved do
      transitions :from => :request_pick_up, :to => :valet_pick_up
    end

    event :valet_on_route_pick_up do
      transitions :from => :valet_pick_up, :to => :car_pick_up
    end

    event :auth_code_matched_pick_up do
      transitions :from => :car_pick_up, :to => :in_transit_pick_up
    end

    event :keys_dropped do
      transitions :from => :in_transit_pick_up, :to => :car_parked
    end

    event :drop_off_requested do
      transitions :from => :car_parked, :to => :request_drop_off
    end

    event :drop_off_retrieved do
      transitions :from => :request_drop_off, :to => :valet_drop_off
    end

    event :valet_on_route_drop_off do
      transitions :from => :valet_drop_off, :to => :in_transit_drop_off
    end

    event :auth_code_matched_drop_off do
      transitions :from => :in_transit_drop_off, :to => :car_drop_off
    end

    event :transaction_complete do
      transitions :from => :car_drop_off, :to => :rating
    end

    event :rating_complete do
      transitions :from => :rating, :to => :completed
    end
  end

  def remove_valet_pick_up
    unless self.valet_pick_up = nil
      self.valet_pick_up = nil
    end
  end

  def remove_valet_drop_off
    unless self.valet_drop_off = nil
      self.valet_drop_off = nil
    end
  end

  belongs_to :user
  belongs_to :valet_pick_up, class_name: "Valet"
  belongs_to :valet_drop_off, class_name: "Valet"
  belongs_to :source_location, class_name: "Location"
  belongs_to :parking_location, class_name: "Location"
  belongs_to :destination_location, class_name: "Location"
end
