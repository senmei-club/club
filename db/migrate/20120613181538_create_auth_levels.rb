class CreateAuthLevels < ActiveRecord::Migration
  def change
    create_table :auth_levels do |t|
      t.integer :id
      t.integer :level
      t.string :allowed_path
      t.string :action

      t.timestamps
    end
  end
end
