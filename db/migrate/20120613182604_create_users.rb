class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.integer :id
      t.string :name
      t.string :nickname
      t.integer :age
      t.string :cellphone
      t.string :address
      t.string :card_id
      t.integer :auth_level

      t.timestamps
    end
  end
end
