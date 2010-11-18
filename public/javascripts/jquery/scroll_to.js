;(function($){
  $.scrollTo = function(target){
    var $target = $(target).eq(0);
    
    var $focus_field = $('<input type="text" />').css({
      width: "1px",
      height: "1px",
      border: "0px",
      backgroundColor: "transparent",
      "float": "left",
      position: 'absolute',
      top: $target.offset().top,
      left: $target.offset().left
    });

    $focus_field.appendTo('body').focus().delay(100).remove();
  }
})(jQuery);