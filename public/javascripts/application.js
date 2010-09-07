var CharacterForm = {
  setup: function(selector){
    var form = $(selector);

    form.find('#character_types .character_type').click(function(){
      CharacterForm.set_character_type(this)
    }).tooltip({
      id: 'tooltip',
      delay: 0,
      bodyHandler: function(){
        return $('#description_character_type_' + $(this).attr('value')).html();
      }
    });

    form.find('input[type=submit]').click(function(e){
      e.preventDefault();

      Spinner.show();

      var callback = function(){
        Spinner.hide();

        form.submit();

        Spinner.show(200);
      };

      FB.Connect.requireSession(callback, callback, true);
    });

    form.find('a.skip').click(function(e){
      var link = e.target;

      e.preventDefault();

      Spinner.show();

      var callback = function(){
        document.location = $(link).attr('href');

        Spinner.show(200);
      }
      
      FB.Connect.requireSession(callback, callback, true);
    });
  },

  set_character_type: function(selector){
    var $this = $(selector);

    $this.addClass('selected').
      siblings('.character_type').removeClass('selected');

    $('#character_character_type_id').val(
      $this.attr('value')
    );
  }
}

var Character = {
  update: function(a){
    var c = a.character;
    
    $("#co .basic_money .value").text(c.formatted_basic_money);
    $("#co .vip_money .value").text(c.formatted_vip_money);
    $("#co .experience .value").text(c.experience + "/" + c.next_level_experience);
    $("#co .experience .percentage").css({width: c.level_progress_percentage + "%"})
    $("#co .level .value").text(c.level);
    $("#co .health .value").text(c.hp + "/" + c.health_points);
    $("#co .energy .value").text(c.ep + "/" + c.energy_points);
    $("#co .stamina .value").text(c.sp + "/" + c.stamina_points);

    Timer.start('#co .health .timer', c.time_to_hp_restore, this.update_from_remote);
    Timer.start('#co .energy .timer', c.time_to_ep_restore, this.update_from_remote);
    Timer.start('#co .stamina .timer', c.time_to_sp_restore, this.update_from_remote);

    $('#co .timer').click(this.update_from_remote)

    c.points > 0 ? $("#co .level .upgrade").show() : $("#co .level .upgrade").hide();
    c.hp == c.health_points ? $('#co .health .hospital').hide() : $('#co .health .hospital').show();
  },

  update_from_remote: function(){
    $.getJSON('/character_status/' + character_key + "?rand=" + Math.random(), function(data){
      Character.update(data)
    });
  },

  initFightAttributes: function(){
    $('#fight_attributes .inventories .inventory').tooltip({
      delay: 0,
      track: true,
      showURL: false,
      bodyHandler: function(){
        return $('#' + $(this).attr('tooltip')).clone();
      }
    })
  }
};

var PropertyList = {
  enableCollection: function(timer_element){
    $(timer_element).parent('.timer').hide();
    $(timer_element).parents('.property_type').find('.button.collect').show();

    var collectables = $('#property_collect_all').find('.value');

    collectables.text(parseInt(collectables.text()) + 1);
    collectables.parent().show();
  }
}

var Timer = {
  timers: {},

  format: function(value){
    var days    = Math.floor(value / 86400);
    var hours   = Math.floor((value - days * 86400) / 3600);
    var minutes = Math.floor((value - days * 86400 - hours * 3600) / 60);
    var seconds = value - days * 86400 - hours * 3600 - minutes * 60;

    var result = '';

    if(days > 1){
      result = result + days + ' days, ';
    } else if(days > 0) {
      result = result + days + ' day, ';
    }

    if(hours > 0){
      result = result + hours + ":";
    }

    if(minutes < 10){
      result = result + "0" + minutes;
    }else{
      result = result + minutes;
    }

    if(seconds < 10){
      result = result + ":0" + seconds;
    }else{
      result = result + ":" + seconds;
    }

    return(result);
  },

  update: function(id){
    var element = $(id);

    if(element == null){
      this.timers[id].running = false;

      return
    }

    if(this.timers[id].value > 0){
      element.text(Timer.format(this.timers[id].value));

      this.timers[id].value = this.timers[id].value - 1;

      this.rerun(id);
    }else{
      element.text('');

      this.timers[id].running = false;

      if(this.timers[id].callback){
        this.timers[id].callback(element);
      }
    }
  },

  rerun: function(id){
    setTimeout(function() { Timer.update(id); }, 1000);
    this.timers[id].running = true;
  },

  start: function(id, value, callback){
    if(value == 0){ return; }

    if(this.timers[id]){
      this.timers[id].value = value;
      this.timers[id].callback = callback;
    } else {
      this.timers[id] = {value: value, running: false, callback: callback};
    }

    if(!this.timers[id].running){
      this.rerun(id);
    }
  }
};

var BossFight = {
  initBlock: function(){
    $(document).bind({
      'boss.won': BossFight.onWin,
      'boss.lost': BossFight.onLose,
      'boss.expired': BossFight.onExpire
    });
  },
  onWin: function(event, fight_id){
    BossFight.hide_reminder(fight_id);
  },
  
  onLose: function(event, fight_id){
    BossFight.hide_reminder(fight_id);
  },

  onExpire: function(event, fight_id){
    BossFight.hide_reminder(fight_id);
  },

  hide_reminder: function(fight_id){
    $('#boss_fight_' + fight_id).hide();

    if($('#boss_fight_block .boss_fight:visible').length == 0){
      $('#boss_fight_block').hide();
    }
  }
}

var AssignmentForm = {
  setup: function(){
    $('#new_assignment .tabs').tabs();

    $('#new_assignment .relations .relation').click(AssignmentForm.select_relation)
  },

  select_relation: function(){
    $('#new_assignment .relations .relation').removeClass('selected');

    var $this = $(this);

    $this.addClass('selected');

    $('#assignment_relation_id').val($this.attr('value'));
  }
}

var Equipment = {
  setup: function(){
    $('#equippables .inventory, #placements .inventory').tooltip({
      delay: 0,
      track: true,
      bodyHandler: function(){
        return $(this).find('.tooltip_content').clone();
      }
    })
  }
}

var Mission = {
  requirementCallback: function(){},
  onRequirementSatisfy: function(){
    $(document).unbind('requirement.satisfy', Mission.onRequirementSatisfy);

    Mission.requirementCallback();
  },
  onItemPurchase: function(){
    $(document).unbind('item.purchase', Mission.onItemPurchase);
    $(document).trigger('requirement.satisfy');
  }
}

var Spinner = {
  x: -1,
  y: -1,
  setup: function(){
    $('#spinner').
      ajaxStart(function(){
        Spinner.show();
      }).
      ajaxStop(function(){
        Spinner.hide();
      });
    $('body').mousemove(this.alignToMouse);
  },
  show: function(speed){
    Spinner.moveToPosition();

    $('#spinner').fadeIn(speed);
  },
  hide: function(speed){
    $('#spinner').fadeOut(speed)
  },
  blink: function(speed, delay){
    Spinner.moveToPosition();

    $('#spinner').fadeIn(speed).delay(delay).fadeOut(speed);
  },
  storePosition: function(x, y){
    Spinner.x = x;
    Spinner.y = y;
  },
  moveToPosition: function(){
    if(this.x > -1 && this.y > -1){
      $('#spinner').css({
        top: this.y - $('#spinner').height() - 50
      })
    }
  },
  alignToMouse: function(e){
    Spinner.storePosition(e.pageX, e.pageY)
  },
  alignTo: function(selector){
    var position = $(selector).offset();

    Spinner.storePosition(position.left, position.top);
  }
}

$(function(){
  if(document.cookie.indexOf(session_id) == -1){
    $('a').live('click', function(){
      var url = $(this).attr('href');

      url = url + (url.indexOf('?') == -1 ? '?' : '&') + '_session_id=' + session_id;

      $(this).attr('href', url);
    });

    $('form').live('submit', function(){
      $(this).append('<input type="hidden" name="_session_id" value="' + session_id + '">');
    });

    $.ajaxSetup({
      beforeSend : function(request){
        request.setRequestHeader('session-id', session_id);
      }
    });
  }

  FB_RequireFeatures(['Base', 'Api', 'Common', 'XdComm', 'CanvasUtil', 'Connect', 'XFBML'], function(){
    FB.XdComm.Server.init("/xd_receiver.html");

    FB.CanvasClient.set_timerInterval(1)
    FB.CanvasClient.startTimerToSizeToContent();

    // This is beta feature, we should be sure that it won't break anything
    try{ FB.CanvasClient.syncUrl(); } catch(e){}

    // Manually set canvas height to be sure that it will fit to content size
    FB.CanvasClient.setCanvasHeight($('body').outerHeight());

    FB.init(facebook_api_key, "/xd_receiver.html", {debugLogLevel: 2});

    $(document).trigger('facebook.ready');
  });

  $(document).bind('result.received', function(){
    $(document).trigger('remote_content.received');
    $(document).trigger('result.available')
  });

  $(document).bind('result.available', show_result)

  $(document).bind('remote_content.received', function(){
    FB.XFBML.Host.parseDomTree();
  });

  $(document).bind('loading.dialog', function(){
    $.scrollTo('#content');
  });
  
  $(document).bind('afterReveal.dialog', function(){
    $.scrollTo('#dialog .popup .body');
  });

  $(document).bind('facebook.stream_publish', function(){
    $.scrollTo('#content');
    Spinner.alignTo('#content');
    Spinner.blink();
  })

  Spinner.setup();

  $('a.help').live('click', function(e){
    e.preventDefault();
    
    $.dialog({ajax: $(this).attr('href')});
  });

  $(document).bind('dialog.close_complete application.ready', function(){
    $(document).dequeue('dialog');
  });
});

function bookmark(){
  FB.Connect.showBookmarkDialog();

  $.scrollTo('body');
}

function show_result(){
  $('#result').show();

  $.scrollTo('#result');
}