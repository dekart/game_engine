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

    if(element.length === 0){
      this.timers[id].running = false;

      return;
    }

    if(this.timers[id].value > 0){
      element.text(Timer.format(this.timers[id].value));

      this.timers[id].value = this.timers[id].value - 1;

      this.rerun(id);
    } else {
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
    if(value === 0){ return; }

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


var Spinner = {
  x: -1,
  y: -1,
  enabled: true,
  
  setup: function(){
    $('#spinner').ajaxStart(Spinner.show).ajaxStop(Spinner.hide);
      
    $('body').mousemove(Spinner.alignToMouse);
  },
  show: function(speed){
    if(!Spinner.enabled){ return; }
    
    Spinner.moveToPosition();

    $('#spinner').fadeIn(speed);
  },
  hide: function(speed){
    $('#spinner').fadeOut(speed);
  },
  blink: function(speed, delay){
    if(!Spinner.enabled){ return; }

    Spinner.moveToPosition();

    $('#spinner').fadeIn(speed).delay(delay).fadeOut(speed);
  },
  storePosition: function(x, y){
    Spinner.x = x;
    Spinner.y = y;
  },
  moveToPosition: function(){
    if(Spinner.x > -1 && Spinner.y > -1){
      $('#spinner').css({
        top: Spinner.y - $('#spinner').height() / 2
      });
    }
  },
  alignToMouse: function(e){
    Spinner.storePosition(e.pageX, e.pageY);
  },
  alignTo: function(selector){
    var position = $(selector).offset();

    Spinner.storePosition(position.left, position.top);
  },
  disable: function(callback){
    Spinner.enabled = false;
    callback.call(this);
    Spinner.enabled = true;
  }
};


function if_fb_initialized(callback){
  if(typeof FB !== 'undefined'){ 
    callback.call();
  } else { 
    alert('The page failed to initialize properly. Please reload it and try again.'); 
  }
}

function show_result(){
  $('#result').hide().fadeIn(500);

  $.scrollTo('#result');
}

function signedUrl(url){
  var url_parts = url.split('#', 2);
  
  var new_url = url_parts[0] + (url_parts[0].indexOf('?') == -1 ? '?' : '&') + 'stored_signed_request=' + signed_request;
  
  if(url_parts.length == 2) {
    new_url = new_url + '#' + url_parts[1];
  }

  return new_url;
}

function redirectTo(url){
  document.location = signedUrl(url);
}

function updateCanvasSize() {
  FB.Canvas.setSize({
    height: $('body').height() + 100 // Additional number compensates admin menu margin that is not included into the body height
  });
}


var CollectionList = {
  setup: function(){
    CollectionList.blurItems($('#item_collection_list').find('.info .item:not(.present)'));
  },

  blurItems: function(collection){
    collection.removeClass('present').children().css({opacity: 0.4, filter: ''});
  }
};


var CharacterForm = {
  setup: function(selector){
    var form = $(selector);

    form.find('#character_types .character_type').click(function(){
      CharacterForm.set_character_type(this);
    }).qtip({
      show: {
        delay : 0
      },
      content: {
        text: function(){
          return $('#description_character_type_' + $(this).attr('value')).html();
        }
      }
    });

    form.find('input[type=submit]').click(function(e){
      e.preventDefault();

      form.submit();

      Spinner.show(200);
    });

    form.find('a.skip').click(function(e){
      var link = e.target;

      e.preventDefault();

      redirectTo($(link).attr('href'));

      Spinner.show(200);
    });
  },

  set_character_type: function(selector){
    var $this = $(selector);

    $this.addClass('selected').siblings('.character_type').removeClass('selected');

    $('#character_character_type_id').val(
      $this.data('value')
    );
  }
};


var Character = {
  update: function(a){
    if(typeof a === 'undefined' || a === null){ return; }
    
    var c = a.character;

    if($.isEmptyObject(c)){ return; }
    
    $("#co .basic_money .value").text(c.formatted_basic_money);
    $("#co .vip_money .value").text(c.formatted_vip_money);
    $("#co .experience .value").text(c.experience + "/" + c.next_level_experience);
    $("#co .experience .percentage").css({width: c.level_progress_percentage + "%"});
    $("#co .level .value").text(c.level);
    $("#co .health .value").text(c.hp + "/" + c.health_points);
    $("#co .energy .value").text(c.ep + "/" + c.energy_points);
    $("#co .stamina .value").text(c.sp + "/" + c.stamina_points);

    Timer.start('#co .health .timer', c.time_to_hp_restore, this.update_from_remote);
    Timer.start('#co .energy .timer', c.time_to_ep_restore, this.update_from_remote);
    Timer.start('#co .stamina .timer', c.time_to_sp_restore, this.update_from_remote);

    $('#co .timer').unbind('click').click(Character.update_from_remote);

    if (c.points > 0) {
      $("#co .level .upgrade").show();
    } else {
      $("#co .level .upgrade").hide();
    }
    
    if (c.hp == c.health_points) {
      $('#co .health .hospital').hide();
    } else {
      $('#co .health .hospital').show();
    }
    
    if (c.ep > (c.energy_points / 2)) {
      $('#co .energy .refill').hide();
    } else {
      $('#co .energy .refill').show();
    }
    
    if (c.sp > (c.stamina_points / 2)) {
      $('#co .stamina .refill').hide();
    } else {
      $('#co .stamina .refill').show();
    }
    
  },

  update_from_remote: function(){
    $.getJSON('/character_status/?rand=' + Math.random(), function(data){
      Character.update(data);
    });
  }
};


var PropertyList = {
  enableCollection: function(timer_element){
    $(timer_element).parent('.timer').hide();
    $(timer_element).parents('.property_type').find('.button.collect').show();

    var collectables = $('#property_collect_all').find('.value');

    collectables.text(parseInt(collectables.text(), 10) + 1);
    collectables.parent().show();
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

    if($('#boss_fight_block .boss_fight:visible').length === 0){
      $('#boss_fight_block').hide();
    }
  }
};


var AssignmentForm = {
  setup: function(){
    $('#new_assignment .tabs').tabs();

    $('#new_assignment .relations .relation').click(AssignmentForm.select_relation);
  },

  select_relation: function(){
    $('#new_assignment .relations .relation').removeClass('selected');

    var $this = $(this);

    $this.addClass('selected');

    $('#assignment_relation_id').val($this.data('value'));
  }
};


var Equipment = {
  setup: function() {
    
    $("#equippables-tabs").tabs({
      show: function(event, ui) {
        $(ui.panel).find(".carousel-container").jcarousel({
          visible: 8,
          itemFallbackDimension: 8
        }); 
      }
    });
    
    $("#placements .additional .carousel-container").jcarousel({
      vertical: true,
      itemFallbackDimension: 3
    });
    
    
    $("#equippables .inventory, #placements .inventory").draggable({
      appendTo: $("#equipment"),
      helper: function() {
        var clone = $(this).clone();
        clone.find("span").remove();
        clone.css('opacity', 0.7);
        return clone;
      },
      revert: "invalid",
      cursor: "move"
    });
    
    var elementInContainer = function(container, el) {
      return $(el).parents("[data-placement='" + $(container).data('placement') + "']").length == 1;
    }
    
    var checkPlacementAcceptance = function(container, el) {
      return $.inArray($(container).data('placement'), $(el).data('placements').split(',')) != -1;
    };
    
    var disableDraggables = function() {
      $("#equippables .inventory").draggable("disable");
      $("#placements .inventory").draggable("disable");
    };
    
    var droppableDefaults = {
      activeClass: "state-active",
      hoverClass: "state-hover",
      activate: function(){ 
        $(this).css('opacity', 0.7);
      },
      deactivate: function(){
        $(this).css('opacity', 1);
      }
    };
    
    $("#placements .placement, #placements .additional .items").droppable($.extend(droppableDefaults, {
      accept: function(el) {
        if ($(this).attr('data-free-slots') == 0) {
          return false;
        }
          
        if (checkPlacementAcceptance(this, el) && !elementInContainer(this, el)) {
          return true;
        }
        return false;
      },
      drop: function(event, ui) {
        disableDraggables();
        
        if ($(ui.draggable).data('move')) {
          // move inventory from one placement to another
          $.post($(ui.draggable).data('move'), {to_placement: $(this).data('placement')}, function(request) {
            $("#result").html(request);
          });
        } else {
          // simply equip inventory in this placement
          $.post($(ui.draggable).data('equip'), {placement: $(this).data('placement')}, function(request) {
            $("#result").html(request);
          });
        }
      }
    }));
    
    $("#equippables-tabs .item_group").droppable($.extend(droppableDefaults, {
      accept: function(el) {
        if ($(el).parents("#equippables-tabs").length == 0) {
          return true;
        }
        return false;
      },
      drop: function(event, ui) {
        disableDraggables();
        
        $.post($(ui.draggable).data('unequip'), {placement: $(ui.draggable).data('placement')}, function(request) {
          $("#result").html(request);
        });
      }
    }));
  },
  
  getActiveTabId: function() {
    return $('#equippables-tabs .ui-tabs-selected a').attr('href');
  },
  
  setActiveTab: function(tabId) {
    if (typeof tabId !== 'undefined') {
      $("#equippables-tabs").tabs('select', tabId);
    }
  }
};


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
};

var Fighting = {
  loadMoreOpponents : function(){
    $.get('/fights', function(response){
      $('#victim_list').append(response);
    });
  }
};

var Contest = {
  setup: function(contestGroup) {
    var $tabs = $(".contest .results .tabs");
    
    if ($tabs.length > 0) {
      $tabs.tabs();
      
      var tabIndex = $tabs.find('.ui-tabs-nav .contest_group').index($('#' + contestGroup));
      $tabs.tabs('select', tabIndex);
    }
  }
};

function debug(s) {
  if(!$.isEmptyObject(console)) {
    console.log(s);
  }
}


(function($){
  $.fn.missionGroups = function(current_group, show_limit){
    var $container = $(this);
    var $items = $container.find('li');
    var $current = $(current_group);

    $container.find('.container').jCarouselLite({
      btnNext:  $container.find('.next'),
      btnPrev:  $container.find('.previous'),
      visible:  show_limit,
      start:    Math.floor($items.index($current) / show_limit) * show_limit,
      circular: false
    });

    $current.addClass('current');

    $items.click(function(e){
      e.preventDefault();
      e.stopPropagation();

      redirectTo($(this).find('a').attr('href'));
    });
  };
  
  $.fn.setupBoost = function(show_limit) {
    var prepare_boosts = function(selector){
      var $boosts = $(selector);
      var $items = $boosts.find('li');
      
      if($items.length == 0){
        return false;
      }
      
      var $current = $boosts.find('.active');

      var startIndex = 0;
      
      if ($items.index($current) != -1) {
        startIndex = Math.floor($items.index($current) / show_limit) * show_limit;
      }

      $boosts.find('.container').jCarouselLite({
        btnNext:  $boosts.find('.next'),
        btnPrev:  $boosts.find('.previous'),
        visible:  show_limit,
        start:    startIndex,
        circular: false
      });
    }
    
    var $selector = $(this).selector;

    prepare_boosts($selector);
    
    $(document).bind('fights.create', {selector : $selector}, function(event){
      prepare_boosts(event.data.selector);
    });
  };
  
  $.fn.giftForm = function(options){
    var $gifts = $(this).find('.gifts .gift');

    $gifts.css({
      height: $gifts.map(function(e){
          return $(this).outerHeight();
        }).toArray().sort().reverse()[0]
    });

    return $(this);
  };
  
  // Chat
  var chatFnMethods = {
    init: function(updateTime) {
      var $chat = $(this);
      $chat.chat('loadMessages');
      
      $chat.find('.send.button').addClass('disabled');
      
      $chat.find('.text').bind('keyup keydown change', function() {
        var $button = $chat.find('.send.button'); 
        
        if ($(this).val() == '') {
          $button.addClass('disabled');
        } else {
          $button.removeClass('disabled');
        }
      });
      
      setInterval(function() {
        $chat.chat('loadMessages');
      }, updateTime * 1000);
    },
    
    lastMessageId: function() {
      var lastMessageId = "";
      if ($(this).find('.message').length > 0) {
        lastMessageId = $(this).find('.message:last').data('message-id');
      }
      return lastMessageId;
    },
    
    loadMessages: function() {
      var $chat = $(this);
      
      Spinner.disable(function(){
        $.getJSON('/chats/' + $chat.data('chat-id'), {last_message_id: $chat.chat('lastMessageId')}, function(messages) {
          $chat.chat('appendMessages', messages);
        
          $(document).trigger('remote_content.received');
        });
      });
    },
    
    appendMessages: function(messages) {
      if (messages.length > 0) {
        var lastReceivedMessageId = $.parseJSON(messages[messages.length - 1]).id;
        var lastMessageId = $(this).chat('lastMessageId');
        
        // prevent double appending, when timer and send query happens
        if (lastReceivedMessageId != lastMessageId) {
          var $messages = $(this).find('.messages');
           
          for (var i = 0; i < messages.length; i++) {
            var message = $.parseJSON(messages[i]);
            var messageContent = $(this).chat('template').tmpl(message);
             
            $messages.append(messageContent);
          }
        
          $(this).find('.container').scrollTop($messages.outerHeight());
        }
      }
    },
    
    template: function() {
      var templateId = $(this).data('template');
      return $('#' + templateId);
    },
    
    onSubmit: function() {
      var $chat = $(this).parent('.chat');
      
      if (!$chat.find('.send.button').hasClass('disabled')) {
        
        var lastMessageId = $chat.chat('lastMessageId');
        
        var data = $(this).serializeArray();
        data.push({name: 'last_message_id', value: lastMessageId});
        
        $.post(
          $(this).attr('action'), 
          $.param(data), 
          function(request) {
            $chat.chat('appendMessages', request)
          }, 
          'json'
        );
        
        var $chatText = $(this).find("[name='chat_text']");
        $chatText.val("");
        $chatText.trigger('change'); 
      }
    }
  };
  
  $.fn.chat = function(method) {
    if ( chatFnMethods[method] ) {
      return chatFnMethods[ method ].apply( this, Array.prototype.slice.call( arguments, 1 ));
    } else {
      $.error('Method ' +  method + ' does not exist on jQuery.chat');
    }
  }

  
  if(!$.isEmptyObject($.fn.qtip)) {
    $.fn.qtip.zindex = 400;
  }
})(jQuery);


$(function(){
  if(document.cookie.indexOf('access_token') == -1){
    $('a').live('click', function(){
      var href = $(this).attr('href') || '';
      
      if(href !== ''){
        $(this).attr('href', signedUrl(href));
      }
    });

    $('form').live('submit', function(){
      $(this).append('<input type="hidden" name="stored_signed_request" value="' + signed_request + '">');
    });

    $.ajaxSetup({
      beforeSend : function(request){
        request.setRequestHeader('signed-request', signed_request);
      }
    });
  }
  
  $(document).bind('tooltips.setup', function(){
    // Display tooltips
    $('#content [data-tooltip]').each(function(){
      var $element = $(this);
      
      $element.qtip($element.data('tooltip'));
    });
  })
  
  $(document).trigger('tooltips.setup');
       
  $('a[data-click-once=true]').live('click', function(){
    $(this).attr('onclick', null).css({opacity: 0.3, filter: '', cursor: 'wait'}).blur();
  });

  $(document).bind('facebook.ready', function(){
    window.setInterval(updateCanvasSize, 100);
  });

  $(document).bind('result.received', function(){
    $(document).trigger('remote_content.received');
    $(document).trigger('result.available');
  });

  $(document).bind('result.available', show_result);

  $(document).bind('remote_content.received', function(){
    if(typeof FB !== 'undefined'){
      FB.XFBML.parse();
    }
    $(document).trigger('tooltips.setup');
  });

  $(document).bind('loading.dialog', function(){
    $.scrollTo('#dialog .popup');
  });
  
  $(document).bind('afterReveal.dialog', function(){
    $.scrollTo('#dialog .popup .body');
  });

  Spinner.setup();

  $('a.help').live('click', function(e){
    e.preventDefault();
    
    $.dialog({ajax: $(this).attr('href')});
  });

  $(document).bind('dialog.close_complete application.ready', function(){
    $(document).dequeue('dialog');
  });
  
  $('#app_requests_counter').qtip({
    position: {
      my: 'top right',
      at: 'bottom left'
    },
    show: {
      delay: 0
    }
  });
});