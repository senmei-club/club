// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require jquery_ujs
//= require bootstrap.min
//= require jquery.ui.all


function flash( obj,duration ){
  $(obj).fadeOut( duration / 2 );
  $(obj).fadeIn(duration / 2 );
}

function get_stay_secs(start_time){
  var now = new Date().getTime();
  var now_sec = parseInt(now / 1000);
  var secs = parseInt(now_sec) - start_time;

  return secs; 
}

function get_elapsed_secs(end_time){
  var now = new Date().getTime();
  var now_sec = parseInt(now / 1000);
  var secs = end_time - parseInt(now_sec);

  if(secs < 0) secs = 0;
    
  return secs; 
}

function secs_to_clock( secs ) {
  var partSeconds = Math.floor(secs) % 60;
  var partMinutes = Math.floor(secs / 60) % 60;
  var partHours = Math.floor(secs / 60 / 60) % 24;
  
  return partHours
    + ":" + (partMinutes < 10 ? ("0" + partMinutes) : partMinutes)
    + ":" + (partSeconds < 10 ? ("0" + partSeconds) : partSeconds);
}

function update_counters(){
  $("#active_boxes_count").html($("div.badge-important").length);
  $("#available_boxes_count").html($("div.badge-success").length); 
}

function countProperties(obj) {
  var prop;
  var propCount = 0;
  
  for (prop in obj) {
    propCount++;
  }
  return propCount;
}

function clear_intervals(){
  interval_ids = $('#interval_ids').val();
  if(interval_ids != ""){
    interval_ids = JSON.parse(interval_ids);
  }
  
  while(interval_ids.length > 0){
    clearInterval(interval_ids.pop());
  }
}

jQuery.fn.extend({  
  timer: function(){

    return this.each(function(){
      // var stay_alert_time = <%=@configs["stay_alert_time"] ||= 900 %>;
      // var elapsed_alert_time = <%=@configs["elapsed_alert_time"] ||= 900 %>;
      var stay_alert_time = $("#stay_alert_time_config").val()
      var elapsed_alert_time = $("#elapsed_alert_time_config").val()
      
      var renew_interval = 1000;
      var flash_interval = 2000;
    
      var tmp_id = $(this).attr("id");
      var tmp_val = $(this).val();
      var interval_ids = $('#interval_ids').val();
      if(interval_ids != ""){
        interval_ids = JSON.parse(interval_ids);
      }
      
      if (tmp_val != 0){
        var timer_type = tmp_id.split("_")[1];

        if(timer_type == "stay"){
          $('#clock_' + tmp_id).html(secs_to_clock(get_stay_secs(tmp_val)));
          if( get_stay_secs(tmp_val) > stay_alert_time){
            $('#clock_' + tmp_id).addClass( "timer_alert" );
            interval_ids.push(setInterval("$('#clock_"+tmp_id+"').html(secs_to_clock(get_stay_secs("+tmp_val+")));flash('#clock_"+tmp_id+"',"+flash_interval+");",renew_interval));
          }else{
            interval_ids.push(setInterval("$('#clock_"+tmp_id+"').html(secs_to_clock(get_stay_secs("+tmp_val+")));",renew_interval));
          }
        }else{
          $('#clock_' + tmp_id).html(secs_to_clock(get_elapsed_secs(tmp_val)));
          if( get_elapsed_secs(tmp_val) < elapsed_alert_time){
            $('#clock_' + tmp_id).addClass( "timer_alert" );
            
            if(get_elapsed_secs(tmp_val) == 0){
              interval_ids.push(setInterval("flash('#clock_"+tmp_id+"',"+flash_interval+");",renew_interval));
            }else{
              interval_ids.push(setInterval("$('#clock_"+tmp_id+"').html(secs_to_clock(get_elapsed_secs("+tmp_val+")));flash('#clock_"+tmp_id+"',"+flash_interval+");",renew_interval));
            }
          }else{
            interval_ids.push(setInterval("$('#clock_"+tmp_id+"').html(secs_to_clock(get_elapsed_secs("+tmp_val+")));",renew_interval));
          }
        }
        
        //store interval values in DOM
        $('#interval_ids').val(JSON.stringify(interval_ids));
      }else{
        $("#clock_"+tmp_id).html("") ;
      }
      
    });
  }
}); 
 
function renew(){
  var r_nos = JSON.parse($("#data_indexes").val()); //.forEach(function(item) { alert(item) });
  var data_tmp = {};

  $.ajax({
    type: 'GET',
    url: '/box_status.json',
    data: {},
    dataType: "json",
    success: function(data){
      data_tmp = data;
      
      clear_intervals();
      
      var customers_count = 0;
      
      for(var i=0; i< r_nos.length; i++) {
        var r_no = r_nos[i];
        
        //#if html room object exist
        if($("#room_"+r_no).length){
        
          if(data_tmp[r_no]["end_time"] > 0){
            //#1, check if room bar need to turn on by 'time elasped'
            $("#"+r_no+"_box_switch").attr("class","badge badge-important");
            //#2, update time secs to div
            $('#timer_elapsed_' + r_no).attr("value",data_tmp[r_no]["end_time"]);
          }else{
            $("#"+r_no+"_box_switch").attr("class","badge badge-success");
            $('#timer_elapsed_' + r_no).attr("value",0);
          }
          
          //#3 manager
          if(data_tmp[r_no]["manager"] == undefined){
            $("#manager_"+r_no).html("");
          }else{
            $("#manager_"+r_no).html(data_tmp[r_no]["manager"]);
          }
          
          //#4 customers
          if(data_tmp[r_no]["customers"] == undefined){
            $("#customer_count_"+r_no).html("");
          }else{
            $("#customer_count_"+r_no).html(data_tmp[r_no]["customers"]);
            customers_count += data_tmp[r_no]["customers"];
          }
          
          //#5 waiters
          var waiters = "";
          for(j=0; j<data_tmp[r_no]["waiters"].length; j++ ){
            if(r_no.match(/^[0-9]{3,3}$/)){           
              waiters += "<li>"+
                "<div class='thumbnail'>" +
                  "<div class='waiter'>"+
                    "<span class='wname_"+ r_no +"_"+ (j+1) +"'>"+ data_tmp[r_no]["waiters"][j]["nickname"] +"</span>:" +
                  "</div>" +
                  "<div class='waiter_stay_time_div'>" +
                    "<span id='clock_timer_stay_"+ r_no +"_"+ (j+1) +"'>"+secs_to_clock(get_stay_secs(data_tmp[r_no]["waiters"][j]["time"]))+"</span>" +
                    "<input id='timer_stay_"+ r_no +"_"+ (j+1) +"' name='timer_stay_"+ r_no +"_"+ (j+1) +"' type='hidden' value='"+ data_tmp[r_no]["waiters"][j]["time"] +"'>" +
                  "</div>" +
                "</div>" +
              "</li>";
            }else{
              waiters += "<li>"+
                "<div class='thumbnail'>" +
                  "<div class='waiter'>"+
                    "<span class='wname_"+ r_no +"_"+ (j+1) +"'>"+ data_tmp[r_no]["waiters"][j]["nickname"] +"</span>" +
                  "</div>" +
                "</div>" +
              "</li>";
            }
          }
          
          if(r_no.match(/^[0-9]{3,3}$/)){
            $("#room_"+r_no+" .waiters .thumbnails").empty();
            $("#room_"+r_no+" .waiters .thumbnails").html(waiters);
          }else{
            $("#room_"+r_no+" .wname_only_container .thumbnails").empty();
            $("#room_"+r_no+" .wname_only_container .thumbnails").html(waiters);
          }
        }
      }

      //set customers
      $("#total_customers_count").html(customers_count);
      $('[id^="timer_"]').timer();
      update_counters();
    }
  });
}
