class Request < ActiveRecord::Base
  include AASM
  aasm :column => :status do 
    state :request_pick_up, :initial => true
    state :valet_pick_up
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
      transitions :from => [:request_pick_up, :car_pick_up], :to => :cancelled
    end

    event :cancel_drop_off do
      transitions :from => [:request_drop_off, :valet_drop_off], :to => :car_parked, :after => :remove_valet_drop_off
    end

    event :pick_up_retrieved do
      transitions :from => :request_pick_up, :to => :car_pick_up
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
    unless self.valet_pick_up.nil?
      self.update(valet_pick_up:  nil)
    end
  end

  def remove_valet_drop_off
    unless self.valet_drop_off.nil?
      self.update(valet_drop_off:  nil)
    end
  end

  def generate_auth_code(drop_off = false)
    auth_code = '%04d' % rand(10 ** 4)
    drop_off ? self.update(auth_code_drop_off: auth_code) : self.update(auth_code_pick_up: auth_code)
  end

  def find_nearest_parking
    self.update(parking_location: ParkingLot.near(self.source_location, 10, units: :km).first)
  end

  def auth_code_check?(auth_code, dropoff = false)
    dropoff ? self.auth_code_drop_off == auth_code : self.auth_code_pick_up == auth_code
  end

  def record_time(dropoff = false)
    current_time = Time.now
    dropoff ? self.update(request_drop_off_time: current_time) : self.update(car_pick_up_time: current_time)
  end

  belongs_to :user
  belongs_to :valet_pick_up, class_name: "Valet"
  belongs_to :valet_drop_off, class_name: "Valet"
  belongs_to :source_location, class_name: "Location"
  belongs_to :parking_location, class_name: "Location"
  belongs_to :destination_location, class_name: "Location"
end
