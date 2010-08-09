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

  $('#character_list #all_ids').click(function(){
    $('#character_list td :checkbox').attr({checked : $(this).attr('checked')});
  });

  $('#character_list :checkbox').click(function(){
    $('#character_list :checked').length > 0 ? $('#character_batch').show() : $('#character_batch').hide();
  })
});