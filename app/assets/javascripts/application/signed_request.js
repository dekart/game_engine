function redirectWithSignedRequest(url, target){
  $('<form method="POST" id="redirect-with-signed-request"></form>').
    attr({action: url, target: target}).
    css({display: 'none'}).
    append(
      $('<input type="hidden" name="signed_request"/>').val(signed_request)
    ).
    appendTo($('body')).
    submit();
}

function localUrl(url){
  if(url.match(/^http[s]?:\/\//) && url.indexOf(document.location.protocol + '//' + document.location.host) != 0){
    return false;
  } else {
    return true;
  }
}

(function($){
  if(typeof signed_request == 'undefined'){ 
    return;
  }
  
  $('a[href]:not([href^="#"], [onclick], [data-remote])').on('click', function(){
    var link = $(this);
    
    if(localUrl(link.attr('href'))){
      redirectWithSignedRequest(link.attr('href'), link.attr('target'));
    
      return false;
    }
  });

  $('form:not(#redirect-with-signed-request)').on('submit', function(){
    var form = $(this);
    
    if(localUrl(form.attr('action'))){
      form.append(
        $('<input type="hidden" name="signed_request" />').val(signed_request)
      );
    
      if(form.find('input[name="_method"]').length == 0){
        form.append(
          $('<input type="hidden" name="_method"/>').val(form.attr('method'))
        );
      }
    }
  });

  $("[data-remote]").live('ajax:beforeSend', function(event, request){
    request.setRequestHeader('signed-request', signed_request);
  });

  $.ajaxSetup({
    beforeSend : function(request){
      request.setRequestHeader('signed-request', signed_request);
    }
  });
})(jQuery);
