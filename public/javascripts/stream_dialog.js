/*global $, if_fb_initialized, FB, Spinner */

var StreamDialog = {
  show: function(post_options, callback){
    var options = $.extend(true, {}, post_options, {
      method: 'stream.publish'
    });

    if_fb_initialized(function(){
      FB.ui(options, function(response){
        callback.call(this, response);
      });

      $(document).trigger('facebook.dialog');
    });
  }
};