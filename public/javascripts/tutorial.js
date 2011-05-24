/**
 * Tutorial module
 * 
 * Provides Tutorial class and adds some methods to $.fn
 */ 

var Tutorial = (function(){
  
  tutorial = {};
  
  var fnMethods = {
    /*
    * Makes target object responsible(clickable) in tutorial layout 
    */
    responsible: function() {
      $(this).addClass('tutorialVisible');
    },
    
    /** 
     * Make some element visible(with white transparency), but not responsible.
     */
    visible: function() {
      
      var offset = $(this).offset();

      var visibleBlock = $('<div></div>').addClass('visibleBlock');
      $('#tutorial_overlay').append(visibleBlock);
      
      visibleBlock.css({
        display: 'none',
        left: offset.left, 
        top: offset.top,
        width: $(this).innerWidth(),
        height: $(this).innerHeight()
      });
      
      visibleBlock.fadeIn('slow');
      
      // resize visible block, if images exists inside block
      $(this).find("img").bind('load', {visibleObject: $(this), visibleBlock: visibleBlock}, function(e){
        
        e.data.visibleBlock.css({
          width: e.data.visibleObject.innerWidth(),
          height: e.data.visibleObject.innerHeight()
        });
        
      });
    },
    
    /*
     * Makes target object visible and responsible + binds trigger 
     * to change current tutorial step if user click on object
     */
    clickTarget: function(options) {
      
      $(this).tutorial('responsible');
      $(this).addClass('tutorialScrollTarget');
      
      if (options['redirector_url']) {
        
        // change href param in <a> tag
        var originalHref = encodeURIComponent($(this).attr('href'));
        // TODO: this is very simple link generation and don't consider link params
        var changedHref = options['redirector_url'] + '?redirect_to=' +  originalHref;
        $(this).attr('href', changedHref);
        
        $(this).bind('click', function(){
          // prevent double click
          $(this).removeClass('tutorialVisible');
        });
        
      }
    },
    
    
    /*
     * Show spot circle on center of object 
     */
    spot: function() {
      var spot = $('<div></div>').addClass('spot tutorialScrollTarget');
      $('#tutorial_overlay').append(spot);
      var left = $(this).offset().left + $(this).outerWidth() / 2 - spot.width() / 2;
      var top = $(this).offset().top + $(this).outerHeight() / 2 - spot.height() / 2;
      spot.css({
        display: 'none',
        left: left, 
        top: top 
      });
      spot.fadeIn('slow'); 
    },
    
    
    tip: function(options) {
      var defaultOptions = {
        position: {
          at: 'bottom center',
          my: 'top center'
         },
       show: {
         event: false, 
         ready: true,
        },
        hide: false,
        style: {
          classes: 'ui-tooltip-youtube'
        }
      };
      
      // merge options 
      $.extend(true, defaultOptions, options);
      
      $(this).qtip(defaultOptions);
    }
    
    
  };
  
  
  $.fn.tutorial = function(method) {
    // Method calling logic
    if ( fnMethods[method] ) {
      return fnMethods[ method ].apply( this, Array.prototype.slice.call( arguments, 1 ));
    } else {
      $.error( 'Method ' +  method + ' does not exist on jQuery.tutorial' );
    }
  };
  
  
  // add functions to module
  $.extend(tutorial, {
    
    /*
     * Clear tutorial tips, dialog box and old javascript triggers.
     * This actually after ajax update.
     */
    clearEffects: function() {
      $("#tutorial_overlay").empty();
    
      $(".tutorialScrollTarget").removeClass("tutorialScrollTarget");
      $(".tutorialVisible").removeClass("tutorialVisible");
      
      $(".qtip").qtip("destroy");
    },
    
    /**
     * Fully hide tutorial
     */
    hide: function() {
      $(document).unbind('tutorial');
      Tutorial.clearEffects();
      $('#tutorial').hide();
    },
    
    /**
     * Move dialog after tutorial step block and make it responsible for user interaction.
     */
    prepareDialog: function() {
      // move dialog box after tutorial box
      var newDialogTop =  $('#tutorial_progress').offset().top + $('#tutorial_progress').outerHeight() + 75;
      $('#dialog').offset({ top: newDialogTop });
      $('#dialog').tutorial('responsible');
    },
    
    /**
     * Allow to appear character upgrade dialog. Wait while it closed and
     * triggers next tutorial step
     */
    allowUpgradeDialog: function() {
      
       if ($("#level_up_notification").is(":visible")) {
    
        Tutorial.prepareDialog();
        
        $(document).unbind('character.upgrade_dialog.tutorial')
          .bind('character.upgrade_dialog.tutorial', function() {
            $("#dialog #upgrade_list .points a").hide();
            Tutorial.prepareDialog();
          });
        
        $(document).unbind('character.upgrade_complete.tutorial')
          .bind('character.upgrade_complete.tutorial', function() {
            $(document).trigger('close.dialog');
          });
        
        $(document).unbind('close.dialog.tutorial')
          .bind('close.dialog.tutorial', function() {
            // if dialog was closed, we show our tutorial step
            $(document).trigger('tutorial.show');
          });
            
      } else {
        $(document).trigger('tutorial.show');
      }
    },
    
    /**
     * Execute tutorial step actions
     * 
     * @stepActions - function which contains tutorial step actions
     * @options['change_event'] - event name, which triggers next tutorial step
     * @options['control_upgrade_dialog'] - true/false - close or not popup upgrade character dialogs.
     */
    step: function(stepActions, options) {
      options = options || {};
  
      $(document).unbind('tutorial.show').bind('tutorial.show', function (event){
        
        stepActions();
        
        // scroll browser to target object
        if ($('.tutorialScrollTarget').is(':visible')) 
            $.scrollTo('.tutorialScrollTarget');
      });
        
      if (options['change_event']) {
        Tutorial.ajaxStep(options['change_event'], options);
      }
      
      if (options['control_upgrade_dialog']) {
        Tutorial.allowUpgradeDialog();
      } else {
        $(document).trigger('tutorial.show');
      }
      
    },
    
    /*
     * Show actions for ajax tutorial step.
     * 
     * @changeEvent - executes tutorial step after this event
     * @options['control_upgrade_dialog'] - allow to appear character upgrade dialog. 
     *                                      Tutorial step shows after dialog close.
     */
    ajaxStep: function(changeEvent, options) {
      changeEvent += '.tutorial';
  
      $(document).unbind(changeEvent).bind(changeEvent, changeEvent, function(event) {
        $(document).unbind(event.data);
        
        Tutorial.clearEffects();
        // fire loading next tutorial step
        $(document).trigger('tutorial.next_step');
      });
    },
    
    
    /**
     *  Show tutorial dialog box.
     */
    showDialog: function(options) {
      $(document).queue('dialog', function() {
        
        // hack on dialog settings. we save old settings and restore it after show dialog
        // it needs for change settings only for tutorial dialog
        var oldSettings = $.dialog.settings;
        
        $.extend($.dialog.settings, {overlay: false});
        
        var title = "";
        if (options['content']['title']) {
          title = "<h2>" + options['content']['title'] + "</h2>";
        }
        
        var content = "<div class='tutorial'>" + title + "<div class='content'>" + options['content']['text'] + "</div></div>";
        
        $.dialog(content);
        
        Tutorial.prepareDialog();
        
        $.dialog.settings = oldSettings;
      });
    }
    
    
    
  });
  
  return tutorial;
}());