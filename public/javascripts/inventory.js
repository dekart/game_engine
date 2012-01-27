var Inventory = (function(){
  var inventory = {};

  $.extend(inventory, {
    setup: function(){
      var inventory_tabs = $('#inventory_tabs');

      inventory_tabs.tabs({
        cache: true
      });

      $(document).bind('used.items sold.items', function(e, data){
        var element = $('#' + data.inventory_id);

        if(data.amount > 0) {
          element.find('.picture .count').html(data.amount);

          if(e.type == 'used') {
            element.find('.use.button').linkLock('unlock');
          } else {
            element.find('.sell.button').linkLock('unlock');
          }
        } else {
          element.remove();
        }
      });

    }
  });

  return inventory;
})();