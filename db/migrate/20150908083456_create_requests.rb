class CreateRequests < ActiveRecord::Migration
  def change
    create_table :requests do |t|
      t.string :status
      t.string :auth_code_pick_up
      t.datetime :car_pick_up_time
      t.string :bay_number
      t.datetime :request_drop_off_time
      t.string :auth_code_drop_off
      t.integer :rating_pick_up
      t.integer :rating_drop_off
      t.decimal :tip
      t.decimal :total
      t.timestamps null: false
    end
  end
end
