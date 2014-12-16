#encoding: utf-8
class BoxStatusController < ApplicationController
  layout "common"

  def _get_config
    @configs = Hash[ SysConfig.all.map { |config| [config.config_name, config.config_value ] } ]
    
    @users = Hash[ User.all.map { |user| [user.card_id,{ id: user.id, nickname: user.nickname , user_type: user.user_type } ] } ]    
    @managers = {}
    User.where( user_type: 4 ).all.map do |user|
      @managers.merge!({ "#{user.nickname}" => user.id })
    end
  end
  
  def index
    @configs = Hash[ SysConfig.all.map { |config| [config.config_name, config.config_value ] } ]

    @managers = {}
    User.where( user_type: 4 ).all.map do |user|
      @managers.merge!({ "#{user.nickname}" => user.id })
    end
  
    @bs,@machine_map,@box_id_map = {},{},{}
    Box.all.map do |box|
    
      @bs.merge!({
        "#{box.r_no}" => { 
          id: box.id,
          machine_id: box.machine_id ,
          r_no: box.r_no,
          name: box.name,
          css: box.css_class,
          size_type: box.size_type,
          max: box.display_users,
          cols: box.display_cols,
          users_per_col: box.display_users / box.display_cols,
         # more: false,
          waiters: []
        }
      })
      
      @box_id_map.merge!({ "#{box.id}" => box.r_no })
      @machine_map.merge!({ "#{box.machine_id}" => box.r_no})
    end
      
    now_time = Time.now
    if now_time.localtime > Time.local(now_time.year,now_time.month,now_time.day,12,0,0)
      time_condition = "date_add"
    else
      time_condition = "date_sub"
    end

    #using subquery to find users show up today, and get the maximun time of these users
    # then find these records by user_card_id and time, Then these records will be the newest record
    @user_records = UserBoxRecord.find_by_sql("
      select *
      from user_box_records b right join (
        select ubr.card_id, max(ubr.time) time, u.display, u.id user_id, u.nickname nickname
          from user_box_records ubr
          left join users u on ubr.card_id = u.card_id
        where 
          time > #{time_condition}(current_date, interval 12 hour)
          and u.display = 1
        group by card_id
      ) as a 
      on (a.time = b.time and a.card_id = b.card_id) 
      where b.time > #{time_condition}(current_date, interval 12 hour) 
    ");
    
      @user_records.each do |ur|
    if @user_records
        #filter only female employee

        data = {
          nickname: ur.nickname.nil? ? ur._card_id : ur.nickname[0..4]  ,
          time: ur.time.to_i,
          id: ur.user_id.nil? ? ur.card_id : ur.user_id
        }
        
        if @bs[@machine_map[ur.machine_id]]
          @bs[@machine_map[ur.machine_id]][:waiters] << data
          #@bs[@machine_map[ur.machine_id]][:more] = true if @bs[@machine_map[ur.machine_id]][:waiters].size > @bs[@machine_map[ur.machine_id]][:max]
        else
          p "machine_id: #{ur.machine_id} , r_no: #{@machine_map[ur.machine_id]} not exists in @bs"
        end
      end
    end

    current_time = Time.now.to_i   
    @box_records = BoxRecord.where("start_time < FROM_UNIXTIME(?) and end_time > FROM_UNIXTIME(?) ",  current_time, current_time).all
    
    @total_customers = 0
    if @box_records
      @box_records.each do |br|
        @total_customers += br.customers.to_i
        if @bs[@box_id_map["#{br.box_id}"]]
          @bs[@box_id_map["#{br.box_id}"]][:end_time] = br.end_time.to_i 
          @bs[@box_id_map["#{br.box_id}"]][:manager] = (@managers.invert[br.manager_id] )
          @bs[@box_id_map["#{br.box_id}"]][:customers] = br.customers
        end
      end
    end
    
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @bs }
    end
    
  end
  
  def show
    _get_config
    #id here is box_id
    box_id = params[:id]
    box = Box.find(box_id)
    
    @bs = {
      id: box.id,
      r_no: box.r_no,
      name: box.name,
      machine_id: box.machine_id
    }

    current_time = Time.now.to_i    
    @box_record = BoxRecord.where(" box_id = ? and start_time < FROM_UNIXTIME(?) and end_time > FROM_UNIXTIME(?) ", box_id, current_time, current_time).first
    
    if !@box_record.nil?
      #@bs.merge! @box_record.as_json

      @bs.merge!({
        box_record_id: @box_record.id,
        box_id: @box_record.box_id,
        start_time: @box_record.start_time,
        end_time: @box_record.end_time,
        manager_id: @box_record.manager_id,
        customers: @box_record.customers
      })
    end
    
    #user
    now_time = Time.now
    if now_time.localtime > Time.local(now_time.year,now_time.month,now_time.day,12,0,0)
      time_condition = "date_add"
    else
      time_condition = "date_sub"
    end
      
    @user_records = UserBoxRecord.find_by_sql("
      select *
      from user_box_records b right join (
        select card_id,max(time) time from user_box_records 
        where time > #{time_condition}(current_date, interval 12 hour) 
        group by card_id
      ) as a 
      on (a.time = b.time and a.card_id = b.card_id)
      where b.time > #{time_condition}(current_date, interval 12 hour) 
      and machine_id = #{box.machine_id}
    ;");
     
    
    if @user_records
      @user_records.map! do |ur|
        if !@users[ur.card_id].nil?
          next if @users[ur.card_id][:user_type] != 1
          
          data = {
            nickname: @users[ur.card_id][:nickname] ,
            time: ur.time.to_i,
            id: @users[ur.card_id][:id]
          }
        else
          data = {
            nickname: ur.card_id ,
            time: ur.time.to_i,
            id: ur.card_id
          }
        end
        
        @bs[:waiters] ||= []
        @bs[:waiters] << data
      end
    end
    
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @box_records }
    end
  end

end
