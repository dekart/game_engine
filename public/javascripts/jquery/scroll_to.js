;(function($){
  $.scrollTo = function(target){
    var $target = $(target).eq(0);
    var $offset = $target.offset();

    var styles = {
      width: "1px",
      height: "1px",
      border: "0px",
      backgroundColor: "transparent",
      "float": "left",
      position: 'absolute',
      left: $offset.left
    };

    $('<input type="text" />').css(styles).
      css({ top: $offset.top + $target.outerHeight() }).
      appendTo('body').
      focus().
      delay(100).
      remove();

    $('<input type="text" />').css(styles).
      css({ top: $offset.top }).
      appendTo('body').
      focus().
      delay(100).
      remove();
  }
})(jQuery);