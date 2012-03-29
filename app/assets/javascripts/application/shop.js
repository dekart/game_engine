var Shop = (function(){
  var shop = {};

  $.extend(shop, {
    setup: function(){
      this.setupTabs();
      this.setupAmountSelector();

      $('#shop_tabs').find('.item_list').each(function(){
        shop.setupItemList(this);
      });
    },

    setupTabs: function(){
      var shop_tabs = $("#shop_tabs");

      shop_tabs.tabs({
        cache: true,
        load: this.onTabLoad
      });

      $.History.bind(function(state){
        switch(state){
          case 'services':
            shop_tabs.tabs('select', shop_tabs.tabs('length') - 2);
            break;

          case 'buy_vip_money':
            shop_tabs.tabs('select', shop_tabs.tabs('length') - 1);
            break;
        }
      });
    },

    setupAmountSelector: function(){
      $("#content").on('change', 'select.amount', function(e){
        var el = $(e.currentTarget);

        var amount  = el.val();
        var data    = el.data('options');

        if(data.basic_price > 0){
          $("#item_" + data.id + " .requirements .basic_money .value").html(data.basic_price * amount);
        }

        if(data.vip_price > 0){
          $("#item_" + data.id + " .requirements .vip_money .value").html(data.vip_price * amount);
        }
      });
    },

    setupItemList: function(list){
      var list = $(list);
      var items = list.find('.item');

      var max_height = items.map(function(){
        return $(this).outerHeight();
      }).toArray().sort(function(i,j){ return i > j ? -1 : 1; })[0];

      items.height(max_height);
    },

    // Events

    onTabLoad: function(event, ui){
      shop.setupItemList($(ui.panel).find('.item_list'));
    }
  });

  return shop;
})();