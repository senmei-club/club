#encoding: utf-8
class ReportsController < ApplicationController

  layout "common" 

  #cancan auth
  load_and_authorize_resource
  
  def index  
  
    @bs = {}
    Box.all.map do |box|
      @bs.merge!({ box.name => box.id }) if box.name.match("^[0-9]{3,3}$")
    end

    @users,@user_ids,@usernames = {},{},{}
    User.all.map do |user| 
      @users.merge!( { user.card_id => { id: user.id, nickname: user.nickname , user_type: user.user_type }} )
      @usernames.merge!({ user.id => user.nickname})
      @user_ids.merge!({user.nickname => user.id}) if user.user_type != 0 
    end
    
    @reports_resort = {}

    if !params["report"].nil?
      @start_time = Time.local(
        params["report"]["start_time(1i)"].to_i, 
        params["report"]["start_time(2i)"].to_i, 
        params["report"]["start_time(3i)"].to_i, 
        params["report"]["start_time(4i)"].to_i, 
        params["report"]["start_time(5i)"].to_i, 
        0
       )
       
      @end_time = Time.local(
        params["report"]["end_time(1i)"].to_i, 
        params["report"]["end_time(2i)"].to_i, 
        params["report"]["end_time(3i)"].to_i, 
        params["report"]["end_time(4i)"].to_i, 
        params["report"]["end_time(5i)"].to_i, 
        59
       )
      
      if params["user_id"]
        $user_cond = " and ubr.user_id = #{params["user_id"]} " 
      else
        $user_cond = ""
      end
      
      if params["box_id"]
        $box_cond = " and ubr.box_id = #{params["box_id"]} " 
      else
        $box_cond = ""
      end
      
      @reports = Report.find_by_sql("
        select distinct br.id,br.box_id, br.start_time, br.end_time, br.manager_id, ubr.user_id, ubr.card_id, ubr.time
          from box_records br
          left join user_box_records ubr on ( br.box_id = ubr.box_id and ubr.time > br.start_time and ubr.time < br.end_time  #{$user_cond} #{$box_cond})
        where start_time >= '#{@start_time}' and end_time <= '#{@end_time}' 
          and br.box_id in (select id from boxes b where b.r_no REGEXP '^[0-9]{3,3}$')
        order by start_time asc, br.box_id asc, ubr.time asc;
      " )
      
      logger.debug  @reports
      
      @reports.each do |report|   

        @reports_resort[report.id] ||= {
          box_id: report.box_id,
          manager_id: report.manager_id,
          start_time: report.start_time,
          end_time: report.end_time,
          waiters: {}
        }

        if !report.card_id.nil?
          @next_record = UserBoxRecord.where("card_id = ? and time > ?", report.card_id, report.time).group("card_id").having("min(time)").first
          leave_time = @next_record.nil? ? nil : @next_record.time
           
          @reports_resort[report.id][:waiters][report.user_id] ||= []
          @reports_resort[report.id][:waiters][report.user_id] << {
            entry_time: report.time,
            leave_time: leave_time        
          }
        end
      end
      
    end
    
    #.page params[:page]
  end

  def show
    #@report = Box.find(params[:id])
  end

end
