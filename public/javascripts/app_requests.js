var AppRequests = (function(){
  var app_requests = {};
  
  $.extend(app_requests, {
    setup: function(index){
      this.setupTabs(index);
    },
    
    setupTabs: function(index){
      var app_request_tabs = $("#app_request_tabs");
      
      app_request_tabs.tabs({
        cache: true,
        selected: index
      });
    }
    
  });
  
  return app_requests;
})();
