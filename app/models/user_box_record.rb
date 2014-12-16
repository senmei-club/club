#encoding: utf-8
class UserBoxRecord < ActiveRecord::Base
  attr_accessible :id, 
                  :data_string, 
                  :box_id, 
                  :card_id, 
                  :machine_id, 
                  :time, 
                  :record_type, 
                  :user_character_id, 
                  :user_id,
                  :pre_record_id

  belongs_to :box
  belongs_to :user
                  
  #before_save :parse_data_string
  @@valid_record_type = [5,9]
  
  #do no update if record time less than current record time in db
  def update_current_box_record
    data = {
      card_id: card_id,
      data_string: data_string,
      user_id: user_id,
      box_id: box_id,
      machine_id: machine_id,
      time: time
    }

    ucbr = UserCurrentBoxRecord.where(card_id: card_id).first

    if ucbr.nil?
      UserCurrentBoxRecord.new(data).save
    else
      if ucbr.time < time
        ucbr.data_string = data_string
        ucbr.box_id = box_id
        ucbr.machine_id = machine_id
        ucbr.time = time
        ucbr.save
      end
    end

  end

  def binary_string_wrapper(boxes_id_map, debug = false)
  
    p self.data_string if !debug.nil?
    msg_type = self.data_string[2..3].to_i(16)

    if msg_type != 60
      p "#{self.data_string} is not a in/out message, ignored, type : #{msg_type}" if !debug.nil?
      return false
    end

    if @@valid_record_type.include?( self.data_string[4.. 5].to_i(16)) 
      self.record_type = 1
    else
      p "#{self.data_string} card_id not valid for box #{self.data_string[ 0.. 1].to_i(16) -1}" if !debug.nil?
      return false
    end
  
    self.machine_id = self.data_string[ 0.. 1].to_i(16) -1 #1
    self.box_id = boxes_id_map[self.machine_id.to_s] if !boxes_id_map[self.machine_id.to_s].nil?
    # data_string[ 2.. 3].to_i(16) #2
    # record_type #3
    # data_string[ 6.. 7].to_i(16) #4

    y = data_string[ 8.. 9].to_i(16) #5
    m = data_string[10..11].to_i(16) #6
    d = data_string[12..13].to_i(16) #7
    h = data_string[14..15].to_i(16) #8
    i = data_string[16..17].to_i(16) #9
    s = data_string[18..19].to_i(16) #10
    self.time = "20#{y}-#{m}-#{d} #{h}:#{i}:#{s}"
    self.user_character_id = "%05d" % "#{self.data_string[22..23]}#{self.data_string[20..21]}".to_i(16) #12#11
    self.card_id = "%05d" % "#{self.data_string[26..27]}#{self.data_string[24..25]}".to_i(16) #14#13 last 5 chars of card
    
    #put it here to prevent new user added when db_renew not restart
    user_tmp =  User.where( card_id: self.card_id).first 
    self.user_id = user_tmp.id if !user_tmp.nil?
    
    #rec. = data_string[28..29].to_i(16) #15 reserved
    #rec. = data_string[30..31].to_i(16) #16 controller id
    
    if !debug.nil?
      p "Machine_id id 1: #{self.machine_id}, set2: #{self.data_string[ 2.. 3].to_i(16)}, record_type 3: #{self.record_type}, 
         set4: #{self.data_string[ 6.. 7].to_i(16)} , time 5-10: #{ self.time } , user_char_id 11-12: #{self.user_character_id},
         card_id 13-14: #{self.card_id} , set15: #{self.data_string[28..29].to_i(16)} , controller_id: #{self.data_string[30..31].to_i(16)}"
    end
   
  end
  
  def next_record
    #now = Time.now
    #if self.time.hour > 12
      
  
    #@next_record = UserBoxRecord.where("card_id = ? and time > ? and time < ?", self.card_id, self.time, ).order("time asc").first
    #leave_time = @next_record.nil? ? nil : @next_record.time
          
  end
end
