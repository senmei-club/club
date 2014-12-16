#encoding: utf-8
class User < ActiveRecord::Base
  attr_accessible :id,
                  :card_id,
                  :account, 
                  :password,
                  :name, 
                  :nickname,
                  :user_type,
                  :auth_level,
                  :display
            
  has_many :box_records, as: :manager
  has_many :user_box_records

  ROLES = %w[user accountant admin system_admin]
  
  def role?
    ROLES[auth_level]
  end
  
  def user?
    auth_level == 0
  end
  
  def accountant?
    auth_level == 1
  end
  
  def admin?
    auth_level == 2
  end
  
  def system_admin?
    auth_level == 3
  end
  
  def display?
    display == true
  end
end
