#encoding: utf-8
require "digest/md5"
class ApplicationController < ActionController::Base
  protect_from_forgery
  
  before_filter :check_login
  
  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, :alert => "沒有權限！需要修改資料請使用有管理權限之帳號登入！"
  end
  
  def check_login
    return redirect_to({controller: :www, action: :login}) if session["user"].nil? or session["user"][:id].nil?
  end
  
  def current_user 
    User.find(session["user"][:id])
  end
  
  def current_ability
    @current_ability ||= Ability.new(current_user)
  end
  
end