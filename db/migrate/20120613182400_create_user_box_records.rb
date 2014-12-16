class CreateUserBoxRecords < ActiveRecord::Migration
  def change
    create_table :user_box_records do |t|
      t.integer :id
      t.string :data_string
      t.integer :user_id
      t.string :card_id
      t.integer :box_id
      t.string :machine_id
      t.integer :type
      t.datetime :time
      t.string :user_character

      t.timestamps
    end
  end
end
