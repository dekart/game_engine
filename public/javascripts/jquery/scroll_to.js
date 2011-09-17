;(function($){
  $.scrollTo = function(target){
    var $target = $(target).eq(0);
    var $offset = $target.offset();
    
    $offset && window.FB && FB.Canvas.scrollTo(0, $offset.top);
  }
})(jQuery);