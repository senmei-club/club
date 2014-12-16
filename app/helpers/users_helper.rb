#encoding: utf-8
module UsersHelper

  @@auth_level_map = {0=> "一般使用者", 1=> "會計師" , 2=> "管理員" }
  @@user_type_map = { 0=>"系統帳號" ,1 => "女性員工", 2 => "男性員工" , 3 => "打掃人員", 4 => "經理" }

  def auth_level_to_string(auth_level)
    @@auth_level_map.has_key?(auth_level) ? @@auth_level_map[auth_level] : ""
  end

  def user_type_to_string(user_type )
    @@user_type_map.has_key?(user_type) ? @@user_type_map[user_type] : ""
  end
  
  def auth_level_map
    @@auth_level_map.invert
  end
  
  def user_type_map
    @@user_type_map.invert
  end
end