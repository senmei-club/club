#encoding: utf-8
class BoxRecord < ActiveRecord::Base
  attr_accessible :id, 
                  :box_id, 
                  :start_time, 
                  :end_time, 
                  :manager_id,
                  :customers
                  
  belongs_to :box
  belongs_to :user, polymorphic: true
  
  def close
    self.end_time = Time.now()
    save
  end
end
