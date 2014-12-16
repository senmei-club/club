#encoding: utf-8
module ReportsHelper

  def sec_to_clock(secs)
  
    seconds = secs % 60
    minutes = (secs / 60) % 60
    hours = (secs / 60 / 60) % 24
  
    minutes < 10 ? ("0#{minutes}") : minutes.to_s
    seconds < 10 ? ("0#{seconds}") : seconds.to_s
    
    return "#{hours}:#{minutes}:#{seconds}"
  end
end