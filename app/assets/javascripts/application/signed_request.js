function isSignedRequest(){
  if(typeof signed_request == 'undefined'){
    return false;
  } else {
    return true;
  }
}

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

function redirectTo(url){
  if(isSignedRequest()){
    redirectWithSignedRequest(url, null);
  } else {
    document.location = url;
  }
}

function localUrl(url){
  if(url.match(/^http[s]?:\/\//) && url.indexOf(document.location.protocol + '//' + document.location.host) != 0){
    return false;
  } else {
    return true;
  }
}

$(function(){
  $('#content').on('click', 'a[href]:not([href^="#"], [onclick], [data-remote])', function(e){
    if(!isSignedRequest()){ return; }

    var link = $(e.currentTarget);

    if(localUrl(link.attr('href'))){
      redirectWithSignedRequest(link.attr('href'), link.attr('target'));

      return false;
    }
  });

  $('#content').on('submit', 'form:not(#redirect-with-signed-request)', function(e){
    if(!isSignedRequest()){ return; }

    var form = $(e.currentTarget);

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

  $("[data-remote]").on('ajax:beforeSend', function(event, request){
    if(!isSignedRequest()){ return; }

    request.setRequestHeader('signed-request', signed_request);
  });

  $.ajaxSetup({
    beforeSend : function(request){
      if(!isSignedRequest()){ return; }

      request.setRequestHeader('signed-request', signed_request);
    }
  });
});
