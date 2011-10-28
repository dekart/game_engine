(function(){
  $.sliders = function(points) {
  	$("#Attack-slider, #Defence-slider, #Health-slider, #Energy-slider, #Stamina-slider").slider({	
      orientation: "horizontal",
	  range: "min",
	  min: 0,
	  step: 1,
	  max: points,
	  animate: true
    });
  	
    $("#Attack-slider").bind("slide", function(event, ui){
      var max_points = points - ui.value - $("#Defence-slider").slider("value") - $("#Health-slider").slider("value") - $("#Energy-slider").slider("value") - $("#Stamina-slider").slider("value");
    	
      $(this).next("span").html("value: " + ui.value + " max: " + $(this).slider("option", "max"));
    	 
      $("#Defence-slider").slider("option", "max", max_points + $("#Defence-slider").slider("value"));
      $("#Health-slider").slider("option", "max", max_points + $("#Health-slider").slider("value"));
      $("#Energy-slider").slider("option", "max", max_points + $("#Energy-slider").slider("value"));
      $("#Stamina-slider").slider("option", "max", max_points + $("#Stamina-slider").slider("value"));
    });
    
    $("#Defence-slider").bind("slide", function(event, ui){
      var max_points = points - ui.value - $("#Attack-slider").slider("value") - $("#Health-slider").slider("value") - $("#Energy-slider").slider("value") - $("#Stamina-slider").slider("value");
    	
      $(this).next("span").html("value: " + ui.value + " max: " + $(this).slider("option", "max"));
    	
      $("#Attack-slider").slider("option", "max", max_points + $("#Attack-slider").slider("value"));
      $("#Health-slider").slider("option", "max", max_points + $("#Health-slider").slider("value"));
      $("#Energy-slider").slider("option", "max", max_points + $("#Energy-slider").slider("value"));
      $("#Stamina-slider").slider("option", "max", max_points + $("#Stamina-slider").slider("value"));
    });
    
    $("#Health-slider").bind("slidechange", function(event, ui){
      var max_points = points - ui.value - $("#Defence-slider").slider("value") - $("#Attack-slider").slider("value") - $("#Energy-slider").slider("value") - $("#Stamina-slider").slider("value");
      
      $(this).next("span").html("value: " + ui.value + " max: " + $(this).slider("option", "max"));
      
      $("#Defence-slider").slider("option", "max", max_points + $("#Defence-slider").slider("value"));
      $("#Attack-slider").slider("option", "max", max_points + $("#Attack-slider").slider("value"));
      $("#Energy-slider").slider("option", "max", max_points + $("#Energy-slider").slider("value"));
      $("#Stamina-slider").slider("option", "max", max_points + $("#Stamina-slider").slider("value"));
    });
    
    $("#Energy-slider").bind("slidechange", function(event, ui){
      var max_points = points - ui.value - $("#Defence-slider").slider("value") - $("#Health-slider").slider("value") - $("#Attack-slider").slider("value") - $("#Stamina-slider").slider("value");
    	
      $(this).next("span").html("value: " + ui.value + " max: " + $(this).slider("option", "max"));
    	 
      $("#Defence-slider").slider("option", "max", max_points + $("#Defence-slider").slider("value"));
      $("#Health-slider").slider("option", "max", max_points + $("#Health-slider").slider("value"));
      $("#Attack-slider").slider("option", "max", max_points + $("#Attack-slider").slider("value"));
      $("#Stamina-slider").slider("option", "max", max_points + $("#Stamina-slider").slider("value"));
    	
    });
    
    $("#Stamina-slider").bind("slidechange", function(event, ui){
      var max_points = points - ui.value - $("#Defence-slider").slider("value") - $("#Health-slider").slider("value") - $("#Energy-slider").slider("value") - $("#Attack-slider").slider("value");
    	
      $(this).next("span").html("value: " + ui.value + " max: " + $(this).slider("option", "max"));
    	 
      $("#Defence-slider").slider("option", "max", max_points + $("#Defence-slider").slider("value"));
      $("#Health-slider").slider("option", "max", max_points + $("#Health-slider").slider("value"));
      $("#Energy-slider").slider("option", "max", max_points + $("#Energy-slider").slider("value"));
      $("#Attack-slider").slider("option", "max", max_points + $("#Attack-slider").slider("value"));
    });
    	  
  };
})(jQuery);
	
	
	

	

