function debug(s) {
  if(!$.isEmptyObject(console)) {
    console.log(s);
  }
}

var ClanEditForm = {
  setup : function(){
    $(".change").click(function(){
      $(".file").show();
      $(this).hide()
    });
    
    $(".cancel a").click(function(){
      $(".file").hide();
      $(".change").show();
    });
  }
};

var Shop = {
  setup : function(){
    
    $(".amount").change(function(){
      var amount = $(this).val();
      var data = $.parseJSON($(this).attr('data-options'));
      
      if(data['basic_price'] > 0){
        $("#item_" + data['id'] + " .requirements .basic_money .value").html(data['basic_price'] * amount);
      }
        
      if(data['vip_price'] > 0){
        $("#item_" + data['id'] + " .requirements .vip_money .value").html(data['vip_price'] * amount);
      }   
    });
    
  }
};

var Spinner = {
  x: -1,
  y: -1,
  enabled: true,
  
  setup: function(){
    $('#spinner').ajaxStart(Spinner.show).ajaxStop(Spinner.hide);
    $('form:not([target])').live('submit', Spinner.show);
      
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

var jCarouselHelper = {
  wrap: function($container, wrapFactor) {
    var result = "";
    var wrapped = [];
    
    var items = $container.find('li').toArray();
    
    for (var i = 0; i < items.length; i++) {
      var $item = $(items[i]);
      
      wrapped.push($item.html());
      
      if (wrapped.length == wrapFactor || i == items.length - 1) {
        result += '<li>' + wrapped.join("\n") + '</li>';
        wrapped = []
      }
    }
    
    $container.html(result);
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

    $('#co .health .timer').timer(c.time_to_hp_restore, this.update_from_remote);
    $('#co .energy .timer').timer(c.time_to_ep_restore, this.update_from_remote);
    $('#co .stamina .timer').timer(c.time_to_sp_restore, this.update_from_remote);

    $('#co .timer').unbind('click', Character.update_from_remote).bind('click', Character.update_from_remote);

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
    Spinner.disable(function(){
      $.getJSON('/character_status/?rand=' + Math.random(), function(data){
        Character.update(data);
        
        $(document).trigger('application.ready'); // Triggering event to start timers
      });
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
  options: {},
  
  setup: function(_options) {
    if (_options) {
      this.options = _options;
      
      if (this.options.wrapGroupEquipment)
        this.options.groupedPlacementSize /= this.options.wrapGroupEquipment;
    }
    
    $("#equippables-tabs").tabs({
      show: function(event, ui) {
        $(ui.panel).find(".carousel-container").jcarousel({
          visible: 8,
          itemFallbackDimension: 8
        }); 
      }
    });
    
    $('#placements .group_placement').each(function(){
      var $placement = $(this);
      var $carousel = $placement.find('.carousel-container');
      
      // Appending free placeholders
      var free_slots = parseInt($placement.data('free-slots'));
      
      if(free_slots > 0) {
        for(var i = 0; i < free_slots; i ++){
          $carousel.append('<li><div class="additional-placeholder"></div></li>');
        }
      }
      
      if (Equipment.options.wrapGroupEquipment) {
        jCarouselHelper.wrap($carousel, Equipment.options.wrapGroupEquipment);
      }
      
      $carousel.jcarousel({
        vertical: true,
        visible: Equipment.options.groupedPlacementSize,
        // TODO: hack. without it control button is active
        size: $carousel.find("li").length,
        itemFallbackDimension: Equipment.options.groupedPlacementSize
      });
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
    
    $("#placements .placement, #placements .group_placement").droppable($.extend(droppableDefaults, {
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


var Fighting = {
  setup: function(){
    $(document).bind({
      'fights.create': Fighting.checkOpponentPresence,

      'character.new_level': function() {
        $('#victim_list .character').remove();

        Fighting.loadOpponents();
      }
    });
    
    Fighting.checkOpponentPresence();
  },
  
  checkOpponentPresence: function(){
    if($('#victim_list .character:visible').length == 0){
      Fighting.loadOpponents();
    }
  },
  
  loadOpponents : function(){
    $("#loading_opponents").show();
    
    $.get('/fights', function(response){
      $("#loading_opponents").hide();
    }, 'script');
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

var Exchange = {
  setup: function() {
    $("#exchangeables_tabs").tabs({
      show: function(event, ui) {
        $(ui.panel).find(".carousel-container").jcarousel({
          visible: 8,
          itemFallbackDimension: 8
        }); 
      }
    });
    
    $("#exchangeables_tabs .inventory").click(function() {
      $("#exchangeables_tabs .inventory.active").removeClass('active');
      
      $(this).addClass('active');
      $(".exchangeables .button.add").removeClass("disabled");
    });
    
    $("#new_exchange_offer").submit(function() {
      $("#exchange_offer_item_id").val($("#exchangeables_tabs .inventory.active").data('id'));
    });
    
    if ($("#exchangeables_tabs .inventory.active").length == 0) {
      $(".exchangeables .button.add").addClass("disabled");
    }
  }
};

var AchievementList = {
  setup: function() {
    $(document).bind('facebook.permissions.missing facebook.permissions.not_granted', function() {
      $("#achievement_permissions").show();
    }).bind('facebook.permissions.present facebook.permissions.granted', function(){
      $("#achievement_permissions").hide();
    });
    
    FacebookPermissions.test('publish_actions');
  },
  
  requestPermissions: function(){
    FacebookPermissions.request('publish_actions');
  }
};

var Rating = {
  setup: function() {
    $("#rating_list").tabs();
    
    $(document).bind('facebook.permissions.missing facebook.permissions.not_granted', function() {
      $("#rating_score_permissions").show();
    }).bind('facebook.permissions.present facebook.permissions.granted', function(){
      $("#rating_score_permissions").hide();
    });
    
    FacebookPermissions.test('publish_actions');
  },
  
  requestPermissions: function() {
    FacebookPermissions.request('publish_actions');
  }
};

var Boost = {
  inited: {},
  
  prepareBoosts: function(selector, show_limit){
    var $boosts = $(selector);
    var $items = $boosts.find('.boost');
    
    if($items.length == 0){
      return false;
    }
    
    var $current = $boosts.find('.active');
    
    $boosts.find('.container ul').jcarousel({
      visible: show_limit,
      itemFallbackDimension: show_limit,
      start: $items.index($current)
    });
  },
  
  setup: function(type, destination, show_limit) {
    var key = type + "_" + destination;
    
    if (!Boost.inited[key]) {
      Boost.inited[key] = 1;
      
      var $selector = ".boosts." + type + "." + destination;
  
      Boost.prepareBoosts($selector, show_limit);
      
      $(document).bind('boosts.update', {selector: $selector}, function(event){
        Boost.prepareBoosts(event.data.selector, show_limit);
      }).bind('item.purchase', {selector : $selector, type: type, destination: destination}, function(event, options) {
        // update boost view
        var $selector = $(event.data.selector);
        
        var $boost = $selector.find(".boost.not_owned[data-item-id='" + options.item_id + "']");
        
        if ($boost.length > 0) {
          $.post("/inventories/" + options.inventory_id + "/toggle_boost", {destination: event.data.destination}, function(request) {
            $("#ajax").html(request);
          });
        }
      });
    }
  }
};

var FacebookPermissions = {
  test: function(permissions) {
    permissions = permissions.split(",");
    
    FB.getLoginStatus(function(response) {
      if (response.authResponse) {
        // logged in and connected user, someone you know
        FB.api('/me/permissions', function(r) {
          var data = r.data[0]; // TODO: We should handle a case when r.data is undefined (it happens sometimes)
          
          var missingPermissions = [];
          
          for (var i = 0; i < permissions.length; i++) {
            var permission = permissions[i];
            
            if (data[permission] != 1) {
              missingPermissions.push(permission);
            }
          }
          
          if (missingPermissions.length > 0) {
            $(document).trigger('facebook.permissions.missing', missingPermissions);
          } else {
            $(document).trigger('facebook.permissions.present'); 
          }
        });
      } else {
        // no user session available, someone you dont know
      }
    });
  },
  
  request: function(permissions) {
    FB.login(
      function(response){
        if (response.status == 'connected'){
          $(document).trigger('facebook.permissions.granted');
        } else {
          $(document).trigger('facebook.permissions.not_granted');
        }
      }, 
      {
        scope: permissions
      }
    );
  }
};

(function($){
  $.fn.missionGroups = function(current_group, show_limit){
    var $container = $(this);
    var $items = $container.find('li');
    var $current = $(current_group);
    
    $container.find('.container ul').jcarousel({
      visible: show_limit,
      itemFallbackDimension: show_limit,
      start: $items.index($current)
    });
     
    $current.addClass('current');

    $items.click(function(e){
      e.preventDefault();
      e.stopPropagation();

      redirectWithSignedRequest($(this).find('a').attr('href'));
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
      
      Visibility.every(updateTime * 1000, function() {
        $chat.chat('loadMessages');
      });
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
        $.getJSON('/chats/' + $chat.data('chat-id'), {
            last_message_id: $chat.chat('lastMessageId')
          }, 
          function(data) {
            $chat.chat('processData', data);
        });
      });
    },
    
    refreshOnlineList: function(charactersOnline) {
      var $chat = $(this);
      var $content = $(this).find(".online .content");

      if(!charactersOnline || charactersOnline.length == 0){
        $content.empty();
        
        return;
      }
      
      var $template = $("#online-characters-template");
      
      // currentCharacter always first
      var currentCharacter = charactersOnline.shift();
      
      var $characters = $content.find('.character');
      
      // first load
      if ($characters.length == 0) {
        $content.append($template.tmpl(currentCharacter));
      } 
      
      var wasOnline = $characters.map(function() {
        var id = parseInt($(this).data('id'));
        
        if (currentCharacter.facebook_id != id){
          return id;
        }
      }).toArray();
      
      // add new users
      $.each(charactersOnline, function(index, character) {
        if ($.inArray(character.facebook_id, wasOnline) == -1) {
          $content.prepend($template.tmpl(character));
        }
      });
      
      // remove disconnected users 
      var onlineFacebookIds = $.map(charactersOnline, function(e){ return e.facebook_id });
      $.each(wasOnline, function(index, facebookId) {
        if ($.inArray(facebookId, onlineFacebookIds) == -1) {
          $content.find(".character[data-id='" + facebookId + "']").remove();
        }
      });
    },
    
    appendMessages: function(messages) {
      if (messages && messages.length > 0) {
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
        
          $(this).find('.messages-container').scrollTop($messages.outerHeight());
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
          function(data) {
            $chat.chat('processData', data);
          }, 
          'json'
        );
        
        var $chatText = $(this).find("[name='chat_text']");
        $chatText.val("");
        $chatText.trigger('change'); 
      }
    },
    
    processData: function(data) {
      if(!data){
        return;
      }
      
      var $chat = $(this);
      
      $chat.chat('appendMessages', data.messages);
      $chat.chat('refreshOnlineList', data.characters_online);
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
    $.fn.qtip.zindex = 10001;
  }
})(jQuery);


$(function(){
  $(document).bind('tooltips.setup', function(){
    // Display tooltips
    $('#content [data-tooltip]').each(function(){
      var $element = $(this);
      
      $element.qtip($element.data('tooltip'));
    });
    
     // Display tooltip on click
    $('#content [data-tooltip-on-click]').each(function(){
      var $element = $(this);
      
      var existingTooltip = $element.qtip('api');
      var tooltipOptions = $element.data('tooltip-on-click');
      
      if (tooltipOptions.content.ajax) {
        // hide global spinner here
        $element.click(function() {
          Spinner.enabled = false;
        });
        
        $.extend(tooltipOptions.content.ajax, {
          complete: function() {
            Spinner.enabled = true;
          }
        });
      }
      
      if (existingTooltip) {
        tooltipOptions.events = tooltipOptions.events || {};
        
        $.extend(tooltipOptions.events, {
          show: function() {
            existingTooltip.disable();
          },
          hide: function() {
            existingTooltip.enable();
          }
        });
      }
      
      // for multiple tooltips per elemet. See more http://craigsworks.com/projects/qtip2/tutorials/advanced/#multi
      $element.removeData('qtip');
      
      $element.qtip(tooltipOptions);
    });
  })
  
  $(document).trigger('tooltips.setup');
       
  $('a[data-click-once=true]').live('click', function(){
    $(this).attr('onclick', null).css({opacity: 0.3, filter: '', cursor: 'wait'}).blur();
  });

  $(document).bind('facebook.ready', function(){
    Visibility.every(100, updateCanvasSize);
  });

  $(document).bind('result.received', function(){
    $(document).trigger('remote_content.received');
    $(document).trigger('result.available');
  });

  $(document).bind('result.available', show_result);

  $(document).bind('remote_content.received', function(){
    $(document).trigger('tooltips.setup');
    
    if_fb_initialized(function(){
      FB.XFBML.parse();
    });
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
  
  $('#global_chat_icon').qtip({
    position: {
      my: 'top right',
      at: 'bottom left'
    },
    show: {
      delay: 0
    }
  });
});

window.jsLoadedProperly = true;