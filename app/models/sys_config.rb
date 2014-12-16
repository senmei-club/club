#encoding: utf-8
class SysConfig < ActiveRecord::Base
  attr_accessible :id,
                  :config_name, 
                  :config_value, 
                  :name,
                  :description
end
