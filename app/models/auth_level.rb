class AuthLevel < ActiveRecord::Base
  attr_accessible :action, :allowed_path, :id, :level
end
