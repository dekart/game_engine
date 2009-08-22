var root_url;

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
    $('spinner').hide();
  },
  show: function(){
    $('spinner').show();
  }
}

var Character = {
  onNewLevel: function(){},
  onUpgradeComplete: function(){},

  update: function(a){
    $("co_basic_money").setTextValue(a.character.basic_money);
    $("co_vip_money").setTextValue(a.character.vip_money);
    $("co_experience").setTextValue(a.character.experience + "/" + a.character.next_level_experience);
    $("co_experience_percentage").setStyle({width: a.character.level_progress_percentage + "%"})
    $("co_level").setTextValue(a.character.level);
    $("co_health").setTextValue(a.character.hp + "/" + a.character.health);
    $("co_energy").setTextValue(a.character.ep + "/" + a.character.energy);

    if(a.character.points > 0) {
      $("co_point_link").setTextValue("+" + a.character.points);
      $("co_points").show("inline");
    } else {
      $("co_points").hide();
    }
    if(a.character.property_income > 0){
      Timer.start('co_basic_money_timer', a.character.time_to_basic_money_restore, this.updateFromRemote);
    }
    Timer.start('co_health_timer', a.character.time_to_hp_restore, this.updateFromRemote);
    Timer.start('co_energy_timer', a.character.time_to_ep_restore, this.updateFromRemote);
  },
  updateFromRemote: function(){
    new Ajax.Request(root_url + "character_status", {
      "onSuccess": function(data){
        Spinner.hide();
        Character.update(data);
      },
      "scrollToTop": false
    });
  }
}

var Mission = {
  onComplete: function(){},

  setProgress: function(id, value){
    $('mission_' + id).by_class('progress')[0].setInnerFBML(value);
  },
  hideControls: function(id){
    $('mission_' + id).by_class('controls')[0].setTextValue('');
  }
}

var Fight = {
  hideVictim: function(id){
    if($('character_' + id)){
      $('character_' + id).hide();
    }
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

      if(this.timers[id].callback){
        this.timers[id].callback();
      }
    }
  },
  
  rerun: function(id){
    setTimeout(function() { Timer.update(id); }, 1000);
    this.timers[id].running = true;
  },

  start: function(id, value, callback){
    if(value == 0){ return; }

    if(this.timers[id]){
      this.timers[id].value = value;
      this.timers[id].callback = callback;
    } else {
      this.timers[id] = {value: value, running: false, callback: callback};
    }

    if(!this.timers[id].running){
      this.rerun(id);
    }
  }
};

var Inventory = {
  onPurchase: function(){},
  onEquip: function(){},

  Holders: {
    current: null,
    getRequestParams: function(){
      if(this.current){
        var id = this.current.getId();

        if(id != 'self'){
          return 'relation_id=' + id.replace('relation_', '');
        } else {
          return '';
        }
      }
    },
    getHolders: function(){
      return $('inventory_holders').getChildNodes()[0].getChildNodes();
    },
    initialize: function(){
      var holders = this.getHolders();

      for(var i = 0; i < holders.length; i++){
        var h = holders[i];
        
        h.addEventListener('click', this.onClick);
        
        if(h.hasClassName('current')){ this.current = h; }
      }
      
      if(this.current == null){ this.setCurrentHolder('self'); }
    },
    onClick: function(e){
      var holder = e.target;
      while(!holder.hasClassName('holder')){ holder = holder.getParentNode(); }
      
      Inventory.Holders.setCurrentHolder(holder.getId());
      Inventory.Holders.loadPlacements();
    },
    loadPlacements: function(){
      new Ajax.Updater('result',
        root_url + 'inventories/placements?' + this.getRequestParams(),
        {asynchronous:true, evalScripts:true, method:'get'}
      );
      return false;
    },
    setCurrentHolder: function(id){
      var holders = this.getHolders();

      for(var i = 0; i < holders.length; i++){
        var h = holders[i];

        h.removeClassName('current');
      }

      this.current = $(id)
      this.current.addClassName('current');
    }
  }
}

var HelpRequest = {
  create: function(mission_id){
    new Ajax.Request(root_url + "help_requests", {
      parameters: "mission_id=" + mission_id,
      method: "POST",
      "scrollToTop": false,
      "showSpinner": false
    });
  }
}