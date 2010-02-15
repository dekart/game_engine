

var Spinner = {
  hide: function(){
    $('spinner').hide();
  },
  show: function(){
    $('spinner').show();
  }
}



var HelpRequest = {
  create: function(context_id, context_type){
    new Ajax.Request(root_url + "help_requests", {
      parameters: "context_id=" + context_id + "&context_type=" + context_type,
      method: "POST",
      "scrollToTop": false,
      "showSpinner": false
    });
  }
};