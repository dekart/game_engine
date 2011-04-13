/*
 * See http://craigsworks.com/projects/qtip/docs/ for documentation about qTip plugin.
 */

/*
* Makes target object visible and responsible in tutorial layout 
*/
$.fn.tutorialVisible = function() {
  $(this).addClass('tutorialVisible');
};

/*
 * Makes target object visible and responsible + binds trigger 
 * to change current tutorial step if user click on object
 */
$.fn.tutorialClickTarget = function(options) {
  
  $(this).tutorialVisible();
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
  
};

/* 
 * Show tip on target object.
 * You may pass qTip options by @options parameter
 */
$.fn.tutorialTip = function(options) {
  var defaultOptions = {
    show: { ready: true },
    hide: false, 
    style: {
      border: {
         width: 5,
         radius: 10
      },
      padding: 10, 
      textAlign: 'center',
      tip: true, // Give it a speech bubble tip with automatic corner detection
      classes: {
        target: 'tutorialTipTarget'
      }
    }, 
  };
  
  // merge options 
  $.extend(true, defaultOptions, options);
  
  $(this).qtip(defaultOptions);
};

/*
 * Show spot circle on center of object 
 */
$.fn.tutorialSpot = function() {
  var spot = $('<div></div>').addClass('spot tutorialScrollTarget');
  $('#tutorial_overlay').append(spot);
  var left = $(this).offset().left + $(this).outerWidth() / 2 - spot.width() / 2;
  var top = $(this).offset().top + $(this).outerHeight() / 2 - spot.height() / 2;
  spot.css({ left: left, top: top });
};

/*
 * Show tutorial dialog box. It's create by qTip.
 */
$.showTutorialDialog = function(options) {
  var defaultOptions = {
    show: { ready: true },
    hide: false, 
    position: { 
      target: $("#content"),
      corner: 'topMiddle'
    },
    style: {
      width: { max: 350 },
      padding: '14px',
      border: {
        width: 9,
        radius: 9,
        color: '#666666'
      },
      name: 'light',
      classes: {
        target: 'tutorialTipTarget'
      }
    },
  };
  
  // merge options 
  $.extend(true, defaultOptions, options);
 
  $(document.body).qtip(defaultOptions);
};

/*
 * Clear tutorial tips, dialog box and old javascript triggers.
 * This actually after ajax update.
 */
function tutorialClearEffects() {
  $(".tutorialScrollTarget").removeClass("tutorialScrollTarget");
  $(".tutorialVisible").removeClass("tutorialVisible");
  
  $(".tutorialTipTarget").qtip("destroy").removeClass("tutorialTipTarget");
};

function tutorialHide() {
  tutorialClearEffects();
  $('#tutorial').hide();
};

function tutorialPrepareDialog() {
  // move dialog box after tutorial box
  var newDialogTop =  $('#tutorial').offset().top + $('#tutorial').height() + 25;
  $('#dialog').offset({ top: newDialogTop });
  $('#dialog').tutorialVisible();
}



function tutorialAllowUpgradeDialog() {
  
  if ($("#level_up_notification").is(":visible")) {
    
    console.log('Level up detected');
    
    tutorialPrepareDialog();
    
    $(document).unbind('character.upgrade_dialog.tutorial')
      .bind('character.upgrade_dialog.tutorial', function() {
        $("#dialog #upgrade_list .points a").hide();
        tutorialPrepareDialog();
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
}

function step(stepActions, options) {
  options = options || {};
  
  $(document).unbind('tutorial.show').bind('tutorial.show', function (event){
    
    stepActions();
    
    // scroll browser to target object
    // TODO: not work if scroll target appears not immediately (fadeIn effect for example)
    if ($('.tutorialScrollTarget').is(':visible')) 
      $.scrollTo('.tutorialScrollTarget');
  });
  
  if (options['change_event']) {
    ajaxStep(options['change_event'], options);
  }
  
  if (options['control_upgrade_dialog']) {
    tutorialAllowUpgradeDialog();
  } else {
    $(document).trigger('tutorial.show');
  }
}

/*
 * Show actions for ajax tutorial step.
 * Waits for @event and executes after it.
 *
 * @options['control_upgrade_dialog'] - allow to appear character upgrade dialog. 
 *                                      Tutorial step shows after dialog close.
 */
function ajaxStep(changeEvent, options) {
  changeEvent += '.tutorial';
  
  $(document).unbind(changeEvent).bind(changeEvent, function(event) {
    
    tutorialClearEffects();
    // fire loading next tutorial step
    $(document).trigger('tutorial.next_step');
  });
}
