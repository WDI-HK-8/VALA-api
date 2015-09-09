class CreateValetLogs < ActiveRecord::Migration
  def change
    create_table :valet_logs do |t|
      t.string :status
      t.belongs_to :valet, index: true, foreign_key: true
      t.timestamps null: false
    end
  end
end
