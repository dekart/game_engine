var InviteDialog = {
  show: function(type, invite_options, callback){
    var options = $.extend(true, {}, invite_options, {
      dialog : {
        method: 'apprequests',
        data: {
          'type' : type
        }
      },
      request : {
        'type' : type
      }
    });

    if_fb_initialized(function(){
      FB.ui(options.dialog, function(response){
        if(response){
          $('#ajax').load('/app_requests', $.extend({request_id: response.request, to: response.to}, options.request), function(){ 
            callback(); 
          });
        }
      });

      $(document).trigger('facebook.dialog');
    });
  }
}