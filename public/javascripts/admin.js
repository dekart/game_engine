$(function(){
  $.dialog.settings.container = 'body';
  
  FB_RequireFeatures(['Base', 'Api', 'Common', 'XdComm', 'CanvasUtil', 'Connect', 'XFBML'], function(){
    FB.XdComm.Server.init("/xd_receiver.html");

    FB.init(facebook_api_key, "/xd_receiver.html", {debugLogLevel: 2});

    $(document).trigger('facebook.ready');
  });

  $('a.help').live('click', function(e){
    e.preventDefault();

    $.dialog({ajax: $(this).attr('href')});
  });
});