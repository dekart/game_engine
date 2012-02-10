;(function(){
  var fnMethods = {
    lock: function(){
      $(this).data('linkLock', true)
        .css({opacity: 0.3, cursor: 'wait'})
        .blur();
    },

    unlock: function(){
      $(this).data('linkLock', false)
        .css({opacity: 1, cursor: 'pointer'});
    },

    status: function(){
      return $(this).data('linkLock') || false;
    }
  };

  $.fn.linkLock = function(method){
    var result;

    // Method calling logic
    if ( fnMethods[method] ){
      result = fnMethods[ method ].apply( this, Array.prototype.slice.call( arguments, 1 ));
    } else {
      result = fnMethods.lock.apply(this, arguments);
    }

    return result;
  }
})(jQuery);