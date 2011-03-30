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
$.fn.tutorialClickTarget = function() {
  $(this).tutorialVisible();
  $(this).bind('click', function() {
    $("#tutorial").trigger('next_step');
  });
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
  var spot = $('<div></div>').addClass('spot');
  $('#tutorial_overlay').append(spot);
  var left = $(this).offset().left - spot.width() / 2 + $(this).width() / 2;
  var top = $(this).offset().top - spot.height() / 2 + $(this).height() / 2;
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
 * Standard tutorial dialog box with title, text and one button, which close dialog box. 
 */
$.showTutorialStandardDialog = function(title, text, buttonName) {
  text += '<div id="dialog_button"><input type="button" value="' + buttonName + '"/>';
  
  var options = {
    content: {
      title: {
        text: title
      },
      text: text
    }
  };
  
  $.showTutorialDialog(options);
  
  // close dialog window on button click
  $("#dialog_button > input").bind('click', function() {
    $("#tutorial").trigger('next_step');
  });
};

/*
 * Clear tutorial tips, dialog box and old javascript triggers.
 * This actually after ajax update.
 */
function tutorialClearEffects() {
  $(".tutorialVisible").removeClass("tutorialVisible");
  $(".tutorialTipTarget").qtip("destroy").removeClass("tutorialTipTarget");
  // unbind previously binded trigger
  $("#tutorial").unbind('next_step.change_tutorial_step');
};

function tutorialHide() {
  tutorialClearEffects();
  $('#tutorial').hide();
};
