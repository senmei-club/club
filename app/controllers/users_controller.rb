#encoding: utf-8
class UsersController < ApplicationController
  layout "common"
  
  #cancan auth
  load_and_authorize_resource
  
  # GET /users
  # GET /users.json
  def index
    @search = User.search(params[:search])
    @users = @search.order("id DESC").page(params[:page])
    
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @users }
    end
  end

  # GET /users/1
  # GET /users/1.json
  def show
    @user = User.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @user }
    end
  end

  # GET /users/new
  # GET /users/new.json
  def new
    @user = User.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @user }
    end
  end

  # GET /users/1/edit
  def edit
    @user = User.find(params[:id])
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(params[:user])
    @user.password = Digest::MD5.hexdigest(@user.password) if @user.password != ""
    
    respond_to do |format|
      if @user.save
        format.html { redirect_to @user, notice: '使用者建立成功' }
        format.json { render json: @user, status: :created, location: @user }
      else
        format.html { render action: "new" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /users/1
  # PUT /users/1.json
  def update
    @user = User.find(params[:id])
    
    #delete if password blank , prevent to empty password
    params[:user].delete_if { |key,val| (key == "password") and val == ""}
    params[:user]["password"] = Digest::MD5.hexdigest( params[:user]["password"] ) if !params[:user]["password"].nil?

    respond_to do |format|
      if @user.update_attributes(params[:user])
        format.html { redirect_to @user, notice: '使用者資料更新成功' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user = User.find(params[:id])
    @user.destroy

    respond_to do |format|
      format.html { redirect_to users_url }
      format.json { head :no_content }
    end
  end
end
