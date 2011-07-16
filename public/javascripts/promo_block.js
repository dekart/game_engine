(function($){
  $.fn.promoBlock = function(options){
    var options = $.extend(
      {
        delay : 5
      }, 
      options
    );
    
    var block = $(this);
    var pages = block.find('.page');
    
    var max_height = pages.map(function(){
      return $(this).outerHeight();
    }).toArray().sort(function(i,j){ return i > j ? -1 : 1; })[0];
    
    block.height(block.height() + max_height);
    
    pages.first().show().addClass('current');
    
    setInterval(function(){
      var visible_page = pages.filter('.current');
      var next_page = visible_page.next('.page');
      
      if(next_page.length == 0){
        var next_page = pages.first();
      }
            
      visible_page.fadeOut().removeClass('current').queue(function(){ 
        next_page.addClass('current').fadeIn(); 
        
        $(this).dequeue();
      });
    }, options.delay * 1000);
  }
})(jQuery);