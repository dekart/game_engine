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
          $(this).find('img').load(function(event) {
            var new_height = $(this).parents('.page').outerHeight();

            if (new_height > max_height) {
              max_height = new_height;
              $(document).trigger('promo_block.resize');
            }
          });

          return $(this).outerHeight();
        }).toArray().sort(function(i,j){ return i > j ? -1 : 1; })[0];

        $(document).bind('promo_block.resize', function(){
          block.element.height(max_height);
          block.element.find(".previous, .next").height(max_height);
        });

        $(document).trigger('promo_block.resize');

        block.element.hover(block.pauseRotation, block.resumeRotation)

        block.rotate();

        Visibility.every(block.options.delay * 1000, function(){
          if(!block.paused){
            block.rotate();
          }
        });

        block.element.find(".previous").click(function(){
          block.rotateBack();
        });

        block.element.find(".next").click(function(){
          block.rotate();
        });

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
      },

      rotateBack: function(){
        var pages = block.pages();

        var visible_page = pages.filter('.current');
        var previous_page = visible_page.prev('.page');

        if(previous_page.length == 0){
          var previous_page = pages.last();
        }

        if(previous_page[0] != visible_page[0]){
          if(visible_page.length == 0){
            previous_page.addClass('current').show();
          } else {
            visible_page.removeClass('current').fadeOut(function(){
              previous_page.addClass('current').fadeIn();
            });
          }
        }
      }
    };

    block.setup();

    return block;
  };
})(jQuery);