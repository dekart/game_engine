var AppRequests = (function(){
  var app_requests = {};

  $.extend(app_requests, {
    setup: function(){
      $("#app_request_tabs").tabs();
    },
  });

  return app_requests;
})();
