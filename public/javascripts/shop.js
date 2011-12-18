var Shop = (function(){
  var shop = {};

  $.extend(shop, {
    setup: function(){
      this.setupTabs();
      this.setupAmountSelector();
    },

    setupTabs: function(){
      var shop_tabs = $("#shop_tabs");

      shop_tabs.tabs({cache: true});

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
      $(".amount").change(function(){
        var amount = $(this).val();
        var data = $.parseJSON($(this).attr('data-options'), 10);
        
        if(data.basic_price > 0){
          $("#item_" + data.id + " .requirements .basic_money .value").html(data.basic_price * amount);
        }
          
        if(data.vip_price > 0){
          $("#item_" + data.id + " .requirements .vip_money .value").html(data.vip_price * amount);
        }   
      });
    }
  });

  return shop;
})(jQuery);