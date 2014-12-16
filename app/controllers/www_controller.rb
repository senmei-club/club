#encoding: utf-8
class WwwController < ApplicationController

  skip_before_filter :check_login, except: :logout

  def login
    return redirect_to({ controller: :box_status, action: :index}) if !session["user"].nil?
  
    if request.method != "POST"
      @user = User.new 
    else
    
      if (params[:account] == "") or (params[:password] == "")
        flash.now[:notice] = "尚未輸入帳號或密碼!"
        return render template: "www/login"
      end
    
      user = User.where(account: params[:account]).first
      
      if user.nil?
        flash.now[:notice] = "帳號不存在"
      else
        if Digest::MD5.hexdigest(params[:password]) != user.password
          flash.now[:notice] = "密碼錯誤" 
        else
          session[:user] = {id: user.id,auth_level: user.auth_level}

          return redirect_to({ controller: :box_status, action: :index})
        end
      end
    end
  end
  
  def logout
    session["user"] = nil
    return redirect_to("/login")
  end
end
