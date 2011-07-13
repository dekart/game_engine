(function($){
  $.fn.creditPackageForm = function(){
    var $form = $(this);
    var $packages = $form.find('.credit_package');
    
    $packages.click(function(){
      $packages.removeClass('selected');
      
      $(this).addClass('selected').find(':radio').attr('checked', 'true');
    });
    
    $form.find(':radio:checked').parents('.credit_package').addClass('selected');
    
    $form.find('.purchase.button').click(function(){
      FB.ui({
        method: 'pay',
        purchase_type: 'item',
        order_info: parseInt($form.find('input:checked').val())
      });
    });
    
    $form.find('.earn_credits.button').click(function(){
      FB.ui({
        method: 'pay', 
        credits_purchase: true,
        dev_purchase_params: {"shortcut":"offer"}
      });
    });
  };
})(jQuery);
