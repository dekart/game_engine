(function($){
  $.fn.promoBlock = function(options){
    var element = $(this);
    
    // Checking block existance
    var block = element.data('promoBlock');
    
    if(block){
      return block;
    }
    
    var block = {
      element: element,
      options: $.extend(
        {
          delay : 10 // seconds
        }, 
        options
      ),
      paused: false,
      
      setup: function(){
        var max_height = block.pages().map(function(){
          return $(this).outerHeight();
        }).toArray().sort(function(i,j){ return i > j ? -1 : 1; })[0];

        block.element.height(block.element.innerHeight() + max_height);
        
        block.element.hover(block.pauseRotation, block.resumeRotation)
        
        block.rotate();

        setInterval(function(){
          if(!block.paused){
            block.rotate();
          }
        }, block.options.delay * 1000);

        block.element.data({promoBlock: block});
      },
      
      rotate: function(){
        var pages = block.pages();
        
        var visible_page = pages.filter('.current');
        var next_page = visible_page.next('.page');

        if(next_page.length == 0){
          var next_page = pages.first();
        }
        
        if(next_page[0] != visible_page[0]){
          if(visible_page.length == 0){
            next_page.addClass('current').show();
          } else {
            visible_page.removeClass('current').fadeOut(function(){
              next_page.addClass('current').fadeIn();
            });
          }
        }
      },
      
      pauseRotation: function(){
        block.paused = true;
      },
      
      resumeRotation: function(){
        block.paused = false;
      },
      
      pages: function(){
        return block.element.find('.page');
      },
      
      removePage: function(id){
        var page = block.pages().filter('#promo_block_page_' + id).first();
        
        if(page.hasClass('current')){
          block.rotate();
        }
        
        page.remove();
      }
    };
    
    block.setup();
    
    return block;
  };
})(jQuery);