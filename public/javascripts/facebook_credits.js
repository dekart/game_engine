(function($){
  $.fn.creditPackageForm = function(){
    var $form = $(this)
    
    $form.find(':radio').change(function(){
      $form.find('.credit_package').removeClass('selected');
      $(this).parents('.credit_package').addClass('selected')
    });
    
    $form.find(':radio:checked').parents('.credit_package').addClass('selected');
    
    $form.find('.purchase.button').click(function(){
      FB.ui({
        method: 'pay',
        purchase_type: 'item',
        order_info: parseInt($form.find('input:checked').val())
      });
    });
  }
})(jQuery);
