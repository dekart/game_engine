;(function($){
  $.scrollTo = function(target){
    var $target = $(target).eq(0);
    
    var $focus_field = $('<input type="text" />').css({
      width: "1px",
      height: "1px",
      border: "0px",
      backgroundColor: "transparent",
      "float": "left",
      marginTop: "-50px"
    });

    $focus_field.insertBefore($target).focus().remove();
  }
})(jQuery);