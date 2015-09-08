class CreateLocations < ActiveRecord::Migration
  def change
    create_table :locations do |t|
      t.string :category
      t.string :address
      t.string :coordinates, array: true, default:[]
      t.timestamps null: false
    end
  end
end
