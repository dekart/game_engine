var StreamDialog = {
  show: function(post_type, post_options, callback){
    var options = $.extend(true, {}, post_options, {
      method: 'stream.publish',
    });

    if_fb_initialized(function(){
      FB.ui(options, function(response){
        if(response){
          callback();
        }
      });

      $(document).trigger('facebook.dialog');
    });
  }
}