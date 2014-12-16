#encoding: utf-8
class Box < ActiveRecord::Base
  attr_accessible :id, 
                  :machine_id, 
                  :r_no, 
                  :name, 
                  :size_type, 
                  :css_class,
                  :display_users,
                  :display_cols
                  
  has_many :box_records
  has_many :user_box_records
  
end
