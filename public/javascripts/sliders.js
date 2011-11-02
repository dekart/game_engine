(function(){
  $.sliders = function(points) {
  	
  	$("#upgrade_list .hidden_value").val(0);
 
  	$("#upgrade_list .attribute_slider").slider({	
      orientation: "horizontal",
	  range: "min",
	  value: 0,
	  min: 0,
	  step: 1,
	  max: points,
	  animate: true
    });
    
    $("#upgrade_list .attribute_slider").each(function(){
      $(this).slider("option", "step", parseInt($(this).attr("data-count-points")));
    });
   
    $("#upgrade_list .attribute_slider").slider("option","max",points);
    
    slideChange = function(event, ui){
      var other_sliders = $('#upgrade_list .attribute_slider').not(this);
      
      var max_points = points - ui.value;
      
      other_sliders.each(function(){
      	max_points -= $(this).slider('value');
      });
    	
      other_sliders.each(function(){
      	var slider = $(this);
      	var value = slider.slider("value");
      	
      	slider.slider('option', { max: max_points + value, value: value });
      });
      
      var count_points = $(this).attr("data-count-points");
      var character_upgrade = $(this).attr("data-character-upgrade");
      var count_upgrade = (ui.value - (ui.value % count_points)) / count_points;
      var sum_upgrade = count_upgrade * character_upgrade;
      
      $(this).parents(".attribute_item").children(".points").html((sum_upgrade > 0) ? "+ " + sum_upgrade : "");
      $("#upgrade_points").html(max_points);
      
      $(this).siblings(".hidden_value").val(count_upgrade);
    };
    
    $("#upgrade_list .attribute_slider").bind("slide", slideChange);

    
    // Buttons for attribute
    $("#upgrade_list .minus_value_attribute").click(function(e){
      slider = $(this).siblings(".attribute_slider");
    	
      slider.slider("option","value", slider.slider("value") - parseInt(slider.attr("data-count-points")));
     
      slideChange.call(slider,e,{value: slider.slider("value")});
    });
    
    $("#upgrade_list .plus_value_attribute").click(function(e){
    	slider = $(this).siblings(".attribute_slider");
    	
    	slider.slider("option","value", slider.slider("value") + parseInt(slider.attr("data-count-points")));
     
    	slideChange.call(slider,e,{value: slider.slider("value")});
    });
    
  };
})(jQuery);
