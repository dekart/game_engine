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
      var target = $(this);
      
      target.tutorial('responsible');
      target.addClass('tutorialScrollTarget');
      
      if (options['step_update_url']) {
        target.one('click', function(e){
          var link = $(this);

          link.removeClass('tutorialVisible'); // hiding link to avoid double click
          
          e.stopPropagation();
          e.preventDefault();
          
          $.ajax(options['step_update_url'], { 
            data: { no_render : true },
            complete: function(){
              redirectWithSignedRequest(link.attr('href'));
            }
          });
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
      var tutorial_progress = $('#tutorial_progress');
      var newDialogTop;

      if (tutorial_progress.length > 0) {
        newDialogTop = tutorial_progress.offset().top + tutorial_progress.outerHeight();
      } else {
        newDialogTop = $('#content').top;
      }

      $('#dialog').offset({ top: newDialogTop + 50 });
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
        var title = "";
        
        if (options['content']['title']) {
          title = "<h2>" + options['content']['title'] + "</h2>";
        }
        
        var content = "<div class='tutorial'>" + title + "<div class='content'>" + options['content']['text'] + "</div></div>";
        
        $.dialog(content);
        
        Tutorial.prepareDialog();
      });
    }
  });
  
  return tutorial;
}());