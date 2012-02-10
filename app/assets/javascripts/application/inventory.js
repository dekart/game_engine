var Inventory = (function(){
  var inventory = {};

  $.extend(inventory, {
    setup: function(){
      this.setupTabs();

      $('#inventory_tabs').find('.inventory_list').each(function(){
        inventory.setupItemList(this);
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
    },

    setupTabs: function(){
      var inventory_tabs = $('#inventory_tabs');

      inventory_tabs.tabs({
        cache: true,
        load: this.onTabLoad
      });
    },

    setupItemList: function(list){
      var list = $(list);
      var items = list.find('.inventory');

      var max_height = items.map(function(){
        return $(this).outerHeight();
      }).toArray().sort(function(i,j){ return i > j ? -1 : 1; })[0];

      items.height(max_height);
    },

    // Events

    onTabLoad: function(event, ui){
      inventory.setupItemList($(ui.panel).find('.inventory_list'));
    }

  });

  return inventory;
})();