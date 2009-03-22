extend_instance(Element, {
  by_class: function(name){
    var result = [];
    var children = this.getChildNodes()

    for(i=0; i < children.length; i++){
      if(children[i].hasClassName(name)){
        extend_instance(children[i], Element);
        result.push(children[i])
      }
    }
    return result;
  },
  by_tag: function(tag){
    var result = [];
    var children = this.getChildNodes();
    for(i=0; i < children.length; i++){
      console.log(children[i].getTagName());
      if(children[i].getTagName() == tag){
        extend_instance(children[i], Element);
        result.push(children[i])
      }
    }
    return result;
  }
})

var Spinner = {
  hide: function(){
    $('spinner').setStyle({display: "none"});
  }
}

var Character = {
  update: function(a){
    $("co_basic_money").setTextValue(a.character.basic_money);
    $("co_vip_money").setTextValue(a.character.vip_money);
    $("co_experience").setTextValue(a.character.experience + "/" + a.character.next_level_experience);
    $("co_level").setTextValue(a.character.level);
    $("co_health").setTextValue(a.character.hp + "/" + a.character.health);
    $("co_energy").setTextValue(a.character.ep + "/" + a.character.energy);

    if(a.character.points > 0) {
      $("co_point_link").setTextValue("+" + a.character.points);
      $("co_points").show();
    } else {
      $("co_points").hide();
    }
    Timer.start('co_timer_health', a.character.time_to_hp_restore);
    Timer.start('co_timer_energy', a.character.time_to_ep_restore);
  }
}

var Mission = {
  setCompleteness: function(id, value){
    $('mission_' + id).by_class('completeness')[0].setTextValue(value);
  },
  hideControls: function(id){
    $('mission_' + id).by_class('controls')[0].setTextValue('');
  },
  showResult: function(){
    $('mission_result').show();
  }
}

var Fight = {
  showResult: function(){
    $('fight_result').show()
  },
  hideVictim: function(id){
    $('character_' + id).hide();
  }
}

var Timer = {
  timers: {},
  
  format: function(value){
    var minutes = Math.floor(value / 60);
    var seconds = value - minutes * 60;

    if(seconds < 10){
      seconds = "0" + seconds;
    }
    return(minutes + ":" + seconds);
  },
  
  update: function(id){
    if(this.timers[id].value > 0){
      $(id).setTextValue(Timer.format(this.timers[id].value));

      this.timers[id].value = this.timers[id].value - 1;
      
      this.rerun(id);
    }else{
      $(id).setTextValue('');
      
      this.timers[id].running = false;
    }
  },
  
  rerun: function(id){
    setTimeout(function() { Timer.update(id); }, 1000);
    this.timers[id].running = true;
  },

  start: function(id, value){
    if(this.timers[id]){
      this.timers[id].value = value;
    } else {
      this.timers[id] = {value: value, running: false};
    }

    if(!this.timers[id].running){
      this.rerun(id);
    }
  }
}