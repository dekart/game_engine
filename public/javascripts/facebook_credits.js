(function($){
  $.fn.creditPackageForm = function(){
    var $form = $(this)
    
    $form.find('.purchase.button').click(function(){
      FB.ui({
        method: 'pay',
        purchase_type: 'item',
        order_info: parseInt($form.find('input:checked').val())
      });
    });
  }
})(jQuery);
