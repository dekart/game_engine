(function(){
  $.sliders = function(points) {
  	 var average = points / 5;
  	
    $("#Attack-slider").slider({	
      orientation: "horizontal",
	  range: "min",
	  value: average,
	  min: 0,
	  step: 1,
	  max: points,
	  animate: true,
	  slide: function(event,ui){
	  	var points_sum = ui.value + $("#Defence-slider").slider("value") + $("#Health-slider").slider("value") + $("#Energy-slider").slider("value") + $("#Stamina-slider").slider("value");
	  	var recalc = points_sum - points;
	  	$("#rec").html(recalc);
	 
	  	
	  	
	  	$("#Defence-slider").slider("value",$("#Defence-slider").slider("value") - recalculation);
	  	$("#Health-slider").slider("value",$("#Health-slider").slider("value") - recalculation);
	  	$("#Energy-slider").slider("value",$("#Energy-slider").slider("value") - recalculation);
	  	$("#Stamina-slider").slider("value",$("#Stamina-slider").slider("value") - recalculation);
	  	$(this).next("span").html(ui.value);
	  	$("#Defence-slider").next("span").html($("#Defence-slider").slider("value"));
	  	$("#Health-slider").next("span").html($("#Health-slider").slider("value"));
	  	$("#Energy-slider").next("span").html($("#Energy-slider").slider("value"));
	  	$("#Stamina-slider").next("span").html($("#Stamina-slider").slider("value"));
	  }
    });
    
     $("#Defence-slider").slider({	
      orientation: "horizontal",
	  range: "min",
	  value: average,
	  min: 0,
	  max: points,
	  animate: true,
	  slide: function(event,ui){
	  	var recalculation = (points - ui.value) / 4;
	  	
	  	$("#Attack-slider").slider("value",recalculation);
	  	$("#Health-slider").slider("value",recalculation);
	  	$("#Energy-slider").slider("value",recalculation);
	  	$("#Stamina-slider").slider("value",recalculation);
	  }
    });
    
     $("#Health-slider").slider({	
      orientation: "horizontal",
	  range: "min",
	  value: average,
	  min: 0,
	  max: points,
	  animate: true,
	  slide: function(event,ui){
	  	var recalculation = (points - ui.value) / 4;
	  	
	  	$("#Defence-slider").slider("value",recalculation);
	  	$("#Attack-slider").slider("value",recalculation);
	  	$("#Energy-slider").slider("value",recalculation);
	  	$("#Stamina-slider").slider("value",recalculation);
	  }
    });
    
     $("#Energy-slider").slider({	
      orientation: "horizontal",
	  range: "min",
	  value: average,
	  min: 0,
	  max: points,
	  animate: true,
	  slide: function(event,ui){
	  	var recalculation = (points - ui.value) / 4;
	  	
	  	$("#Defence-slider").slider("value",recalculation);
	  	$("#Health-slider").slider("value",recalculation);
	  	$("#Attack-slider").slider("value",recalculation);
	  	$("#Stamina-slider").slider("value",recalculation);
	  }
    });
    
     $("#Stamina-slider").slider({	
      orientation: "horizontal",
	  range: "min",
	  value: average,
	  min: 0,
	  max: points,
	  animate: true,
	  slide: function(event,ui){
	  	var recalculation = (points - ui.value) / 4;
	  	
	  	$("#Defence-slider").slider("value",recalculation);
	  	$("#Health-slider").slider("value",recalculation);
	  	$("#Energy-slider").slider("value",recalculation);
	  	$("#Attack-slider").slider("value",recalculation);
	  }
    });	  
  };
})(jQuery);
	
	
	

	

