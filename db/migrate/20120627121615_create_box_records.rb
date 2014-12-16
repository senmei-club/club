class CreateBoxRecords < ActiveRecord::Migration
  def change
    create_table :box_records do |t|
      t.datetime :start_time
      t.datetime :end_time
      t.integer :box_id
      t.integer :manager_id

      t.timestamps
    end
  end
end
