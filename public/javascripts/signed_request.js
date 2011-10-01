function redirectWithSignedRequest(url, target){
  $('<form method="POST"></form>').
    attr({action: url, target: target}).
    css({display: 'none'}).
    append(
      $('<input type="hidden" name="signed_request"/>').val(signed_request)
    ).
    appendTo($('body')).
    submit();
}

(function($){
  if(typeof signed_request === 'undefined'){
    return;
  }
  
  $('a[href]:not([href^="#"])').live('click', function(){
    redirectWithSignedRequest($(this).attr('href'), $(this).attr('target'));
    
    return false;
  });

  $('form').live('submit', function(){
    $(this).append(
      $('<input type="hidden" name="signed_request" />').val(signed_request)
    );
  });

  $.ajaxSetup({
    beforeSend : function(request){
      request.setRequestHeader('signed-request', signed_request);
    }
  });
})(jQuery);
