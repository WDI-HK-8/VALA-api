class AddRelationshipsToRequests < ActiveRecord::Migration
  def change
    add_reference :requests, :user, references: :users, index: true, foreign_key: true

    add_reference :requests, :valet_pick_up, references: :valets, index: true
    add_foreign_key :requests, :valets, column: :valet_pick_up_id

    add_reference :requests, :valet_drop_off, references: :valets, index: true
    add_foreign_key :requests, :valets, column: :valet_drop_off_id

    add_reference :requests, :source_location, references: :locations, index: true
    add_foreign_key :requests, :locations, column: :source_location_id

    add_reference :requests, :parking_location, references: :locations, index: true
    add_foreign_key :requests, :locations, column: :parking_location_id

    add_reference :requests, :destination_location, references: :locations, index: true
    add_foreign_key :requests, :locations, column: :destination_location_id
  end
end
