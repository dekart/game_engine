(function(){
  $.sliders = function(points) {
  	
  	$("#attack, #defence, #health, #energy, #stamina").val(0);
 
  	$("#Attack-slider, #Defence-slider, #Health-slider, #Energy-slider, #Stamina-slider").slider({	
      orientation: "horizontal",
	  range: "min",
	  value: 0,
	  min: 0,
	  step: 1,
	  max: points,
	  animate: true
    });
    
    $("#Attack-slider, #Defence-slider, #Health-slider, #Energy-slider, #Stamina-slider").slider("option","max",points);
    
    $("#Attack-slider").bind("slide slidechange", function(event, ui){
      var max_points = points - ui.value - $("#Defence-slider").slider("value") - $("#Health-slider").slider("value") - $("#Energy-slider").slider("value") - $("#Stamina-slider").slider("value");
      
      var count_points = $(this).attr("data-count-points");
      var character_upgrade = $(this).attr("data-character-upgrade");
      var count_upgrade = (ui.value - (ui.value % count_points)) / count_points;
      var sum_upgrade = count_upgrade * character_upgrade
      
      $(".attack_points").html((sum_upgrade > 0) ? "+ " + sum_upgrade : "");
      $("#upgrade_points").html(max_points);
      
      $("#attack").val(count_upgrade);
      
      var defence_value = $("#Defence-slider").slider("value"); 
      var health_value	= $("#Health-slider").slider("value"); 
      var energy_value  = $("#Energy-slider").slider("value");
      var stamina_value = $("#Stamina-slider").slider("value");
      
      $("#Defence-slider").slider("option", { max: max_points + defence_value, value: defence_value });
      $("#Health-slider").slider("option", { max: max_points + health_value, value: health_value });
      $("#Energy-slider").slider("option", { max: max_points + energy_value, value: energy_value });
      $("#Stamina-slider").slider("option", { max: max_points + stamina_value, value: stamina_value });
    });
    
    $("#Defence-slider").bind("slide slidechange", function(event, ui){
      var max_points = points - ui.value - $("#Attack-slider").slider("value") - $("#Health-slider").slider("value") - $("#Energy-slider").slider("value") - $("#Stamina-slider").slider("value");
    	
      var count_points = $(this).attr("data-count-points");
      var character_upgrade = $(this).attr("data-character-upgrade");
      var count_upgrade = (ui.value - (ui.value % count_points)) / count_points;
      var sum_upgrade = count_upgrade * character_upgrade;
      	
      $(".defence_points").html((sum_upgrade > 0) ? "+ " + sum_upgrade : "");
      $("#upgrade_points").html(max_points);
      
      $("#defence").val(count_upgrade);
    	
      $("#Attack-slider").slider("option", "max", max_points + $("#Attack-slider").slider("value"));
      $("#Health-slider").slider("option", "max", max_points + $("#Health-slider").slider("value"));
      $("#Energy-slider").slider("option", "max", max_points + $("#Energy-slider").slider("value"));
      $("#Stamina-slider").slider("option", "max",max_points + $("#Stamina-slider").slider("value"));
    });
    
    $("#Health-slider").bind("slide slidechange", function(event, ui){
      var max_points = points - ui.value - $("#Defence-slider").slider("value") - $("#Attack-slider").slider("value") - $("#Energy-slider").slider("value") - $("#Stamina-slider").slider("value");
      
      var count_points = $(this).attr("data-count-points");
      var character_upgrade = $(this).attr("data-character-upgrade");
      var count_upgrade = (ui.value - (ui.value % count_points)) / count_points;
      var sum_upgrade = count_upgrade * character_upgrade;
      
      $(".health_points").html((sum_upgrade > 0) ? "+ " + sum_upgrade : "");
      $("#upgrade_points").html(max_points);
      
      $("#health").val(count_upgrade);
      
      $("#Defence-slider").slider("option", "max", max_points + $("#Defence-slider").slider("value"));
      $("#Attack-slider").slider("option", "max", max_points + $("#Attack-slider").slider("value"));
      $("#Energy-slider").slider("option", "max", max_points + $("#Energy-slider").slider("value"));
      $("#Stamina-slider").slider("option", "max",max_points + $("#Stamina-slider").slider("value"));
    });
    
    $("#Energy-slider").bind("slide slidechange", function(event, ui){
      var max_points = points - ui.value - $("#Defence-slider").slider("value") - $("#Health-slider").slider("value") - $("#Attack-slider").slider("value") - $("#Stamina-slider").slider("value");
    	
      var count_points = $(this).attr("data-count-points");
      var character_upgrade = $(this).attr("data-character-upgrade");
      var count_upgrade = (ui.value - (ui.value % count_points)) / count_points;
      var sum_upgrade = count_upgrade * character_upgrade;
      	
      $(".energy_points").html((sum_upgrade > 0) ? "+ " + sum_upgrade : "");
      $("#upgrade_points").html(max_points);
      
      $("#energy").val(count_upgrade);
    	 
      $("#Defence-slider").slider("option", "max", max_points + $("#Defence-slider").slider("value"));
      $("#Health-slider").slider("option", "max", max_points + $("#Health-slider").slider("value"));
      $("#Attack-slider").slider("option", "max", max_points + $("#Attack-slider").slider("value"));
      $("#Stamina-slider").slider("option", "max",max_points + $("#Stamina-slider").slider("value"));
    	
    });
    
    $("#Stamina-slider").bind("slide slidechange", function(event, ui){
      var max_points = points - ui.value - $("#Defence-slider").slider("value") - $("#Health-slider").slider("value") - $("#Energy-slider").slider("value") - $("#Attack-slider").slider("value");
      
      var count_points = $(this).attr("data-count-points");
      var character_upgrade = $(this).attr("data-character-upgrade");
      var count_upgrade = (ui.value - (ui.value % count_points)) / count_points;
      var sum_upgrade = count_upgrade * character_upgrade
      	
      $(".stamina_points").html((sum_upgrade > 0) ? "+ " + sum_upgrade : "");
      $("#upgrade_points").html(max_points);
      
      $("#stamina").val(count_upgrade);
    	 
      $("#Defence-slider").slider("option", "max", max_points + $("#Defence-slider").slider("value"));
      $("#Health-slider").slider("option", "max", max_points + $("#Health-slider").slider("value"));
      $("#Energy-slider").slider("option", "max", max_points + $("#Energy-slider").slider("value"));
      $("#Attack-slider").slider("option", "max", max_points + $("#Attack-slider").slider("value"));
    });
    
    
    // Buttons for attack attribute
    $(".attack-plus").click(function(){
    	$("#Attack-slider").slider("option","value", $("#Attack-slider").slider("value") + parseInt($("#Attack-slider").attr("data-count-points")));
    });
    
    $(".attack-minus").click(function(){
    	$("#Attack-slider").slider("option","value", $("#Attack-slider").slider("value") - parseInt($("#Attack-slider").attr("data-count-points")));
    });
    
    // Buttons for defence attribute
    $(".defence-plus").click(function(){
    	$("#Defence-slider").slider("option","value", $("#Defence-slider").slider("value") + parseInt($("#Defence-slider").attr("data-count-points")));
    });
    
    $(".defence-minus").click(function(){
    	$("#Defence-slider").slider("option","value", $("#Defence-slider").slider("value") - parseInt($("#Defence-slider").attr("data-count-points")));
    });
    
    // Buttons for health attribute
    $(".health-plus").click(function(){
    	$("#Health-slider").slider("option","value", $("#Health-slider").slider("value") + parseInt($("#Health-slider").attr("data-count-points")));
    });
    
    $(".health-minus").click(function(){
    	$("#Health-slider").slider("option","value", $("#Health-slider").slider("value") - parseInt($("#Health-slider").attr("data-count-points")));
    });
    
    // Buttons for energy attribute
    $(".energy-plus").click(function(){
    	$("#Energy-slider").slider("option","value", $("#Energy-slider").slider("value") + parseInt($("#Energy-slider").attr("data-count-points")));
    });
    
    $(".energy-minus").click(function(){
    	$("#Energy-slider").slider("option","value", $("#Energy-slider").slider("value") - parseInt($("#Energy-slider").attr("data-count-points")));
    });
    
    // Buttons for stamina attribute
    $(".stamina-plus").click(function(){
    	$("#Stamina-slider").slider("option","value", $("#Stamina-slider").slider("value") + parseInt($("#Stamina-slider").attr("data-count-points")));
    });
    
    $(".stamina-minus").click(function(){
    	$("#Stamina-slider").slider("option","value", $("#Stamina-slider").slider("value") - parseInt($("#Stamina-slider").attr("data-count-points")));
    });
    	  
  };
})(jQuery);
	
	
	

	

