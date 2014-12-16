class CreateBoxes < ActiveRecord::Migration
  def change
    create_table :boxes do |t|
      t.integer :id
      t.string :machine_id
      t.string :name
      t.integer :type

      t.timestamps
    end
  end
end
