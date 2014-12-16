#encoding: utf-8
class BoxRecordsController < ApplicationController
  layout "common"

  before_filter :_get_config, except: [:find_or_create, :destroy, :show ]
  load_and_authorize_resource
  
  def _get_config
    @bs = {}
    Box.all.map do |box|
      @bs.merge!({ "#{box.r_no}" => box.id })
    end
    
    @managers = {}
    User.where( user_type: 4 ).all.map do |user|
      @managers.merge!({ "#{user.nickname}" => user.id })
    end

    @config = SysConfig.where(config_name: "default_box_time_length").first
    
    if @config.nil?
      @config = SysConfig.new({config_name: "default_box_time_length", config_value: 2}).save!
    end
  end
  
  # GET /box_records
  # GET /box_records.json
  def index    
    @search = BoxRecord.search(params[:search])
    @box_records = @search.order("start_time DESC").page params[:page]

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @box_records }
    end
  end

  # GET /box_records/1
  # GET /box_records/1.json
  def show
    @box_record = BoxRecord.find(params[:id])
    
    @bs = {}
    Box.all.map do |box|
      @bs.merge!({ box.id => box.name })
    end

    @users,@usernames = {},{},{}
    User.all.map do |user| 
      @users.merge!( { user.card_id => { id: user.id, nickname: user.nickname , user_type: user.user_type }} )
      @usernames.merge!({ user.id => user.nickname})
    end
    
    @ubrs = UserBoxRecord.where(
      "box_id = ? and time > ? and time < ?", 
      @box_record.box_id , 
      @box_record.start_time,
      @box_record.end_time
    ).order("time desc").all
    
    @waiters = {}
    @ubrs.each do |ubr|   
      if !ubr.card_id.nil?
        @next_record = UserBoxRecord.where("card_id = ? and time > ?", ubr.card_id, ubr.time).group("card_id").having("min(time)").first
        leave_time = @next_record.nil? ? nil : @next_record.time
         
        @waiters[ubr.user_id] ||= []
        @waiters[ubr.user_id] << {
          entry_time: ubr.time,
          leave_time: leave_time        
        }
      end
    end    

    respond_to do |format|
      format.html # show.html.erb
    end
  end


  def find_or_create
    current_time = Time.now.to_i   
    @box_record = BoxRecord.where(" box_id = ? and (start_time < FROM_UNIXTIME(?) and end_time > FROM_UNIXTIME(?)) ",params[:box_id],current_time,current_time).first
    return redirect_to action: "new",box_id: params[:box_id] if @box_record.nil?
    redirect_to edit_box_record_path(@box_record)
  end
  
  
  # GET /box_records/new
  # GET /box_records/new.json
  def new
    current_time = Time.now.to_i    
    @box_record = BoxRecord.where(" box_id = ? and start_time < ? and end_time > ? ",params[:id],current_time,current_time).first
    @box_record = BoxRecord.new(box_id: params[:box], end_time: Time.now + 60 * 60 * @config.config_value.to_i ) if @box_record.nil?
    
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @box_record }
    end
  end

  # GET /box_records/1/edit
  def edit
    @box_record = BoxRecord.find(params[:id])
  end

  # POST /box_records
  # POST /box_records.json
  def create
    @box_record = BoxRecord.new(params[:box_record])  
    
    box_exist = BoxRecord.find_by_sql("
      select * from box_records
      where (
        ( 
          start_time < FROM_UNIXTIME(#{@box_record.start_time.to_i}) 
          and end_time > FROM_UNIXTIME(#{@box_record.start_time.to_i})
        ) OR (
          start_time < FROM_UNIXTIME(#{@box_record.end_time.to_i}) 
          and end_time > FROM_UNIXTIME(#{@box_record.end_time.to_i})      
        )
      ) and (
        box_id = '#{@box_record.box_id}'
      )
    ")
    
    if !box_exist.empty?
      box_ids = box_exist.map!{|br| br.id }

      flash.now[:notice] = "該時段包廂仍在使用中，請更改起始/結束時段。 相關時段記錄ID為: #{box_ids.join(",")}"
      return render action: "new"
    end
    
    if @box_record.save
      redirect_to "/box_status/#{@box_record.box_id}", notice: '包廂開啟記錄建立成功.'
    else 
      render action: "new" 
    end
  end

  # PUT /box_records/1
  # PUT /box_records/1.json
  def update
    @box_record = BoxRecord.find(params[:id])
    
    cur_time = Time.now.to_i
 
       box_exist = BoxRecord.find_by_sql("
        select * from box_records
        where (
          ( 
            start_time < FROM_UNIXTIME(#{@box_record.start_time.to_i}) 
            and end_time > FROM_UNIXTIME(#{@box_record.start_time.to_i})
          ) OR (
            start_time < FROM_UNIXTIME(#{@box_record.end_time.to_i}) 
            and end_time > FROM_UNIXTIME(#{@box_record.end_time.to_i})      
          )
        ) and (
          box_id = '#{@box_record.box_id}'
        ) and (
          id != '#{@box_record.id}'
        )
      ")
 
      if !box_exist.empty?
        box_ids = box_exist.map!{|br| br.id }

        flash.now[:notice] = "該時段包廂仍在使用中，請更改起始/結束時段。 相關時段記錄ID為: #{box_ids.join(",")}"
        return render action: "edit"
      end
      
      if @box_record.update_attributes(params[:box_record])       
        if @box_record.start_time.to_i < cur_time and @box_record.end_time.to_i > cur_time
          redirect_to "/box_status/#{@box_record.box_id}"
        else
          redirect_to @box_record, notice: '包廂開啟記錄更新成功.'
        end
      else
        render action: "edit"
      end
  end

  # DELETE /box_records/1
  # DELETE /box_records/1.json
  def destroy
    @box_record = BoxRecord.find(params[:id])
    @box_record.destroy

    respond_to do |format|
      format.html { redirect_to box_records_url }
      format.json { head :no_content }
    end
  end
  
  def close
    @box_record = BoxRecord.find(params[:id])
    p params[:id]
    @box_record.close
    
    respond_to do |format|
      format.html { redirect_to box_record_path }
      format.json { head :no_content }
    end
  end
end
