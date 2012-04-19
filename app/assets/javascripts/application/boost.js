var Boost = {
  inited: {},
  
  prepareBoosts: function(selector, show_limit){
    var $boosts = $(selector);
    var $items = $boosts.find('.boost');
    
    if($items.length == 0){
      return false;
    }
    
    var $current = $boosts.find('.active');
    
    $boosts.find('.container ul').jcarousel({
      visible: show_limit,
      itemFallbackDimension: show_limit,
      start: $items.index($current)
    });
  },
  
  setup: function(type, destination, show_limit) {
    var key = type + "_" + destination;
    
    if (!Boost.inited[key]) {
      Boost.inited[key] = 1;
      
      var $selector = ".boosts." + type + "." + destination;
  
      Boost.prepareBoosts($selector, show_limit);
      
      $(document).bind('boosts.update', {selector: $selector}, function(event){
        Boost.prepareBoosts(event.data.selector, show_limit);
      }).bind('item.purchase', {selector : $selector, type: type, destination: destination}, function(event, options) {
        // update boost view
        var $selector = $(event.data.selector);
        
        var $boost = $selector.find(".boost.not_owned[data-item-id='" + options.item_id + "']");
        
        if ($boost.length > 0) {
          $.post("/inventories/" + options.item_id + "/toggle_boost", {
            destination: event.data.destination
          });
        }
      });
    }
  }, 
  
  toggle: function(id, type, destination, content) {
    var $selector = $('#' + id);
    
    if ($selector.hasClass("not_owned")) {
      $selector.replaceWith(content);
      
      $(document).trigger('remote_content.received');
    }
    
    $selector.toggleClass('active');
    $('.' + type + '.' + destination +  '.active[id!="' + id + '"]').removeClass('active');
  }
};