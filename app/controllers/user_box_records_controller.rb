#encoding: utf-8
class UserBoxRecordsController < ApplicationController
  layout "common"
  
  load_and_authorize_resource
  # GET /user_box_records
  # GET /user_box_records.json
  
  before_filter :_get_config
  
  def _get_config
    @bs = {}
    Box.all.map do |box|
      @bs.merge!({ "#{box.name}" => box.id })
    end
  end
  
  def index
    @user_box_records = UserBoxRecord.order("time desc").page params[:page]
    @users = Hash[ User.all.map { |user| [user.card_id,{ id: user.id, nickname: user.nickname , name: user.name } ] } ]  
    
    @boxes = {}
    
    Box.all.map do |box|
      @boxes.merge!({
        "#{box.id}" => { 
          machine_id: box.machine_id ,
          r_no: box.r_no,
          name: box.name
        }
      })
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @user_box_records }
    end
  end

  # GET /user_box_records/1
  # GET /user_box_records/1.json
  def show
    @user_box_record = UserBoxRecord.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @user_box_record }
    end
  end

  # GET /user_box_records/new
  # GET /user_box_records/new.json
  def new
    @user_box_record = UserBoxRecord.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @user_box_record }
    end
  end

  # GET /user_box_records/1/edit
  def edit
    @user_box_record = UserBoxRecord.find(params[:id])
  end

  # POST /user_box_records
  # POST /user_box_records.json
  def create
    @user_box_record = UserBoxRecord.new(params[:user_box_record])
    @user_box_record.machine_id = Box.find(params[:user_box_record][:box_id]).machine_id
    
    respond_to do |format|
      if @user_box_record.save
        @user_box_record.update_current_box_record

        format.html { redirect_to @user_box_record, notice: '進出記錄建立成功.' }
        format.json { render json: @user_box_record, status: :created, location: @user_box_record }
      else
        format.html { render action: "new" }
        format.json { render json: @user_box_record.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /user_box_records/1
  # PUT /user_box_records/1.json
  def update
    @user_box_record = UserBoxRecord.find(params[:id])
    @user_box_record.machine_id = Box.find(params[:user_box_record][:box_id]).machine_id

    respond_to do |format|
      if @user_box_record.update_attributes(params[:user_box_record])
        @user_box_record.update_current_box_record

        format.html { redirect_to @user_box_record, notice: '進出記錄更新成功.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @user_box_record.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /user_box_records/1
  # DELETE /user_box_records/1.json
  def destroy
    #Todo: 
    #  update user current box record when record deleted

    @user_box_record = UserBoxRecord.find(params[:id])
    @user_box_record.destroy

    respond_to do |format|
      format.html { redirect_to user_box_records_url }
      format.json { head :no_content }
    end
  end
end
