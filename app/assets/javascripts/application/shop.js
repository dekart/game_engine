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
        onLoad: this.onTabLoad
      });

      $.History.bind(function(state){
        switch(state){
          case 'services':
            shop_tabs.tabs().selectTab('services');
            break;

          case 'buy_vip_money':
            shop_tabs.tabs().selectTab('buy_vip_money');
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

      items.map(function(){
        new VisualTimer(['#timer_' + $(this).attr("id")]).start($('#timer_' + $(this).attr("id")).data('time-left'));
      })
    },

    updateItem: function(selector, code){
      var element = $(selector);

      if(element.length > 0){
        var parent = element.parents('.item_list');

        element.replaceWith(code);

        Shop.setupItemList(parent);
      }
    },

    // Events

    onTabLoad: function(tab, container){
      shop.setupItemList(container.find('.item_list'));
    },

    confirmPurchase: function(link){
      var link = $(link);
      var form = link.parent('form');
      var item = link.parents('.item')

      var amount = form.find('select.amount').val();

      var confirm_text = I18n.t('items.buy_button.confirm', {
        count: amount,
        name: item.find('.name').text(),
        price: [
          item.find('.requirements .basic_money').text(),
          item.find('.requirements .vip_money').text()
        ].join(' ')
      });

      if(amount < 5 || confirm(confirm_text)){
        link.linkLock('lock');

        form.submit();
      }
    }
  });

  return shop;
})();