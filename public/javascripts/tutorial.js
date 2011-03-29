/**
 * Javascript for tutorial
 */
 
/*
* Makes target object visible and responsible in tutorial layout 
*/
$.fn.tutorialVisible = function() {
  $(this).css('position', 'relative').css('z-index', 300);
}

/*
 * Makes target object visible and responsible + binds trigger 
 * to change current tutorial step if user click on object
 */
$.fn.tutorialClickTarget = function() {
  $(this).tutorialVisible();
  $(this).bind('click', function() {
    $(document).trigger('tutorial.next_step');
  });
}

/* 
 * Show tip on target object.
 * You may pass qTip options by @options parameter
 */
$.fn.tutorialTip = function(options) {
  var defaultOptions = {
    show: { ready: true },
    hide: false
  };
  
  // merge options 
  $.extend(true, defaultOptions, options)
  
  $(this).qtip(defaultOptions);
}

/*
 * Show spot circle on center of object 
 */
$.fn.tutorialSpot = function() {
  var spot = $('<div></div>').addClass('spot');
  $('#tutorial_overlay').append(spot);
  var left = $(this).offset().left - spot.width() / 2 + $(this).width() / 2;
  var top = $(this).offset().top - spot.height() / 2 + $(this).height() / 2;
  spot.css({ left: left, top: top });
}
