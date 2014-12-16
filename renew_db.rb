require "rubygems"
require "rails/all"
require "yaml"
require "cancan"

begin
  if !ARGV[0].nil?
    ARGV[0].split.each do |arg|
    
      case arg
        when "d"
          @debug = true
        else
      end
    end
  end
  
  db_conf = YAML.load_file(File.expand_path(File.join(File.dirname(__FILE__),"config/database.yml")))["development"]
  file_conf = YAML.load_file(File.expand_path(File.join(File.dirname(__FILE__),"config/monitor_sys_conf.yaml")))["path"]

  ActiveRecord::Base.establish_connection(db_conf)
    
  log_file_path = File.expand_path(File.join(File.dirname(__FILE__), "log/#{Time.now.strftime "%Y%m%d"}.log"))
  log_file = File.open(log_file_path, "a+")
  @bs = {}
  
  while true
    today = Time.now
    yesterday = Time.now - (60 * 60 * 24)
    today_file= "#{file_conf["msg_file_dir"]}#{today.strftime file_conf["msg_filename_pattern"]}#{file_conf["msg_file_ext"]}"
    yesterday_file= "#{file_conf["msg_file_dir"]}#{yesterday.strftime file_conf["msg_filename_pattern"]}#{file_conf["msg_file_ext"]}"

    if @bs.empty?
      #require all data models
      Dir.glob(File.expand_path(File.join(File.dirname(__FILE__),'app','models','*.rb'))).each do |file|
        require file
      end
    
      Box.all.map do |box|
        @bs.merge!({ "#{box.machine_id}" => box.id })
      end
    end

    p "Start parsing msg file...."
    
    %w[today yesterday].map do |day_name|
      day_file = eval "#{day_name}_file"
      
      p "#{day_name}'s file #{day_file} exists: #{ File.exists?(day_file) }" if !@debug.nil?
      if File.exists?(day_file)
        p "#{Time.now.strftime("%F %T")}: checking for log of #{eval "#{day_name}.strftime('%F')"} .." if !@debug.nil?

        ##new
        f = File.open(day_file,"rb")
        
        #@start_pos means the final row start_byte of this file
        start_pos = f.size - 16
        if start_pos < 0 
          p "file empty" if !@debug.nil?
          
        else
        
          while start_pos >= 0 
            key = File.read(day_file, 16, start_pos).unpack("H*")
            if key.empty?
              p "#{day_name} EOF" if !@debug.nil?
              break
            end

            if UserBoxRecord.where(data_string: key[0]).exists?
              p "key #{key[0]} already exist!" if !@debug.nil?
              break
            end
            
            rec = UserBoxRecord.new(data_string: key[0])
            
            if rec.binary_string_wrapper(@bs,@debug)
              UserBoxRecord.transaction do
                #find the previous record
                # old_rec = UserBoxRecord.where("card_id = ? and time < ?",rec.card_id,rec.time).order("time desc").first
                # rec.pre_record_id = old_rec.id if !old_rec.nil?
                
                if rec.save!
                  rec.update_current_box_record
                  p "Data #{key[0]} Stored! " if !@debug.nil?
                end
              end
            end
              
            start_pos -= 16
          end
        end

      end
    end

    #timeout for five seconds
    sleep 1
  end
rescue => ex
  p ex
  log_file.write Time.now.strftime("%F")
  log_file.write ex
end