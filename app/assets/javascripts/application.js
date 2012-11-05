//= require underscore
//= require jquery
//= require jquery_ujs
//= require jquery-ui/all
//= require i18n
//= require i18n/translations
//= require ./application/visibility
//= require ./libs/jquery/dialog
//= require ./libs/jquery/scroll_to
//= require ./libs/jquery/jcarousel
//= require ./libs/tabs
//= require ./application/signed_request
//= require ./application/link_lock
//= require ./application/spinner
//= require ./application/app_requests
//= require ./application/facebook_credits
//= require ./application/promo_block
//= require ./application/invite_dialog
//= require ./application/stream_dialog
//= require ./application/timer
//= require ./application/visual_timer
//= require ./application/boost
//= require ./application/shop
//= require ./application/inventory
//= require ./application/chat
//= require browser_detect

// Spine-based part of the application
//= require spine/spine
//= require_tree ./models
//= require_tree ./controllers
//= require_tree ./views

//= require_self


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





var PropertyList = {
  enableCollection: function(timer_element){
    $(timer_element).parent('.timer').hide();
    $(timer_element).parents('.property_type').find('.button.collect').show();

    var collectables = $('#property_collect_all').find('.value');

    collectables.text(parseInt(collectables.text(), 10) + 1);
    collectables.parent().show();
  }
};

var AssignmentForm = {
  setup: function(){
    $('#new_assignment #assignment_tabs').tabs();

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

    $('#equipment_tabs .carousel-container').jcarousel({
      visible: 8,
      itemFallbackDimension: 8
    });

    $("#equipment_tabs").tabs();

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
    };

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
          $.post($(ui.draggable).data('move'), {to_placement: $(this).data('placement')});
        } else {
          // simply equip inventory in this placement
          $.post($(ui.draggable).data('equip'), {placement: $(this).data('placement')});
        }
      }
    }));

    $("#equipment_tabs .item_group").droppable($.extend(droppableDefaults, {
      accept: function(el) {
        if ($(el).parents("#equipment_tabs").length == 0) {
          return true;
        }
        return false;
      },
      drop: function(event, ui) {
        disableDraggables();

        $.post($(ui.draggable).data('unequip'), {placement: $(ui.draggable).data('placement')});
      }
    }));
  },

  getActiveTabId: function() {
    return $('#equipment_tabs').tabs().selectedTabId();
  },

  setActiveTab: function(tabId) {
    if (typeof tabId !== 'undefined') {
      $("#equipment_tabs").tabs().selectTab(tabId);
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
    var $tabs = $("#contest_tabs");

    if ($tabs.length > 0) {
      $tabs.tabs();

      $tabs.tabs().selectTab(contestGroup);
    }
  }
};

var Exchange = {
  setup: function() {
    $('#exchangeables_tabs .carousel-container').jcarousel({
      visible: 8,
      itemFallbackDimension: 8
    });

    $("#exchangeables_tabs").tabs();

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
    $("#rating_list").tabs({
      onLoad: function(){
        FB.XFBML.parse();
      }
    });

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

      redirectTo($(this).find('a').attr('href'));
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
})(jQuery);


$(function(){
  var character_overview = new CharacterOverviewController();

  $(document).tooltip({
    items: '[data-tooltip-content]',
    content: function(){
      return $(this).attr('data-tooltip-content');
    }
  });

  $(document).on('click', '[data-item-details-url]', function(e){
    ItemDetailsController.show(e.currentTarget);
  });

  $('#content').on('click', 'a[data-click-once=true]', function(e){
    $(e.currentTarget).attr('onclick', null).css({opacity: 0.3, filter: '', cursor: 'wait'}).blur();
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

  $('#content').on('click', 'a.help', function(e){
    e.preventDefault();
    e.stopPropagation();

    $.dialog({ajax: $(e.currentTarget).attr('href')});
  });

  $(document).bind('dialog.close_complete application.ready', function(){
    $(document).dequeue('dialog');
  });

  // throw error if it in ajax javascript response
  $(document).on('ajax:error', function(event, request, status, error){
    throw error;
  });
});

window.jsLoadedProperly = true;