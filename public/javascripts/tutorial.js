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
$.fn.tutorialClickTarget = function(redirector_url) {
  
  $(this).tutorialVisible();
  $(this).addClass('tutorialScrollTarget');
  
  if (redirector_url) {
    
    // change href param in <a> tag
    var originalHref = encodeURIComponent($(this).attr('href'));
    // TODO: this is very simple link generation and don't consider link params
    var changedHref = redirector_url + '?redirect_to=' +  originalHref;
    $(this).attr('href', changedHref)
    
  } else {
    
    $(this).unbind('click.tutorial.next_step')
      .bind('click.tutorial.next_step', function() {
        $(document).trigger('tutorial.next_step');
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

function tutorialAllowUpdradeDialog() {
  
  if ($(document).queue('dialog').length > 0) {
    
    $(document).unbind('application.ready.tutorial.upgrade_dialog')
      .bind('application.ready.tutorial.upgrade_dialog', function() {
        
        if ($("#level_up_notification").is(":visible")) {
          
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
        }
        
      });
  } else {
    $(document).trigger('tutorial.show');
  }
}


function bindTutorialTrigger(trigger) {
  $(document).unbind('tutorial.next_step')
    .bind('tutorial.next_step', function() {
      tutorialClearEffects();
      trigger();
    });
}

function bindTutorialShow(trigger) {
  $(document).unbind('tutorial.show').bind('tutorial.show', function() {
    trigger();
    if ($('.tutorialScrollTarget').is(':visible')) 
      $.scrollTo('.tutorialScrollTarget');
  });
}

