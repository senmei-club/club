class CreateSysConfigs < ActiveRecord::Migration
  def change
    create_table :sys_configs do |t|
      t.integer :id
      t.string :config_name
      t.string :config_value

      t.timestamps
    end
  end
end
