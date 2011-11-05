(function($){
  var fnMethods = {
    initialize: function(time, callback){
      if(time === 0){
        return;
      }
      
      var timer = $(this);
      
      timer.data({
        fire_at: fnMethods.currentTime() + time,
        callback: callback
      });

      fnMethods.tick.call(this);
    },
    
    tick: function(){
      var timer = $(this);

      if( timer.data('fire_at') > fnMethods.currentTime()){
        timer.text(
          fnMethods.formatValue(timer.data('fire_at') - fnMethods.currentTime())
        );
        
        fnMethods.runTimer.call(this);
      } else {
        timer.empty();
        
        if( timer.data('callback') ){
          timer.data('callback').call(this);
        }
      }
    },

    runTimer: function(){
      var timer = $(this);
      
      $(this).delay(1000).queue(function(next){ fnMethods.tick.call(timer); next(); })
    },
    
    currentTime: function(){
      return Math.round(new Date().getTime() / 1000);
    },
    
    formatValue: function(value){
      var days    = Math.floor(value / 86400);
      var hours   = Math.floor((value - days * 86400) / 3600);
      var minutes = Math.floor((value - days * 86400 - hours * 3600) / 60);
      var seconds = value - days * 86400 - hours * 3600 - minutes * 60;

      var result = '';

      if(days > 1){
        result = result + days + ' days, ';
      } else if(days > 0) {
        result = result + days + ' day, ';
      }

      if(hours > 0){
        result = result + hours + ":";
      }

      if(minutes < 10){
        result = result + "0" + minutes;
      }else{
        result = result + minutes;
      }

      if(seconds < 10){
        result = result + ":0" + seconds;
      }else{
        result = result + ":" + seconds;
      }

      return(result);
    }
  }
  
  $.fn.timer = function(method){
    var result;

    // Method calling logic
    if ( fnMethods[ method ] ){
      result = fnMethods[ method ].apply( this, Array.prototype.slice.call( arguments, 1 ));
    } else {
      result = fnMethods.initialize.apply(this, arguments);
    }

    return result;
  }
})(jQuery);