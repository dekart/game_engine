function signedUrl(url){
  var url_parts = url.split('#', 2);
  
  var new_url = url_parts[0] + (url_parts[0].indexOf('?') == -1 ? '?' : '&') + 'signed_request=' + signed_request;
  
  if(url_parts.length == 2) {
    new_url = new_url + '#' + url_parts[1];
  }

  return new_url;
}

(function($){
  if(typeof signed_request === 'undefined'){
    return;
  }
  
  $('a').live('click', function(){
    var href = $(this).attr('href') || '';
  
    if(href !== ''){
      $(this).attr('href', signedUrl(href));
    }
  });

  $('form').live('submit', function(){
    $(this).append('<input type="hidden" name="signed_request" value="' + signed_request + '">');
  });

  $.ajaxSetup({
    beforeSend : function(request){
      request.setRequestHeader('signed-request', signed_request);
    }
  });
})(jQuery);
