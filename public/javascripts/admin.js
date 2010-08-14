var PayoutList = {
  init: function(object_name){
    $('#payout_list').parents('form').submit(function(){
      $(this).find('.payout').each(function(index){
        $('<input type="hidden" />').
          attr({
            name:   object_name + '[payouts][' + this.id + '][position]',
            value:  index
          }).
          prependTo(this);
      })
    })
  }
}

var RequirementList = {
  init: function(object_name){
    $('#requirement_list').parents('form').submit(function(){
      $(this).find('.requirement').each(function(index){
        $('<input type="hidden" />').
          attr({
            name:   object_name + '[requirements][' + this.id + '][position]',
            value:  index
          }).
          prependTo(this);
      })
    })
  }
}

$(function(){
  $.dialog.settings.container = 'body';
  
  FB_RequireFeatures(['Base', 'Api', 'Common', 'XdComm', 'CanvasUtil', 'Connect', 'XFBML'], function(){
    FB.XdComm.Server.init("/xd_receiver.html");

    FB.init(facebook_api_key, "/xd_receiver.html", {debugLogLevel: 2});

    $(document).trigger('facebook.ready');
  });

  $('form input.submit_and_continue[type=submit]').click(function(){
    $('<input type="hidden" name="continue" value="true">').appendTo($(this).parents('form'));
  });

  $('#flash').click(function(){$(this).remove()}).delay(3000).fadeOut(3000);

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