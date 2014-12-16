#encoding: utf-8
class UserCurrentBoxRecord < ActiveRecord::Base
  attr_accessible :card_id,
                  :data_string,
                  :user_id,
                  :box_id,
                  :machine_id,
                  :time,
                  :create_at 

  set_primary_key :card_id 

  belongs_to :box
  belongs_to :user

  def save_or_update!
    puts self::find(:card_id => card_id)
  end

end

