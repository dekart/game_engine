var AppRequests = (function(){
  var app_requests = {};
  
  $.extend(app_requests, {
    setup: function(){
      this.setupTabs();
    },
    
    setupTabs: function(){
      var app_request_tabs = $("#app_request_tabs");
      
      app_request_tabs.tabs({
        cache: true
      });
    },
    
    // Events

    onTabLoad: function(event, ui){
      shop.setupItemList($(ui.panel).find('.item_list'));
    }
  });
  
  return app_requests;
})();
