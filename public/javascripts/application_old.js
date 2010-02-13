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

  setCharacterType: function(id){
    var previous_id = $('character_character_type_id').getValue()
    var previous    = $('character_type_' + previous_id);
    if(previous) previous.removeClassName('selected');

    var previous_description = $('description_character_type_' + previous_id);
    if(previous_description) previous_description.hide();

    $('character_character_type_id').setValue(id);

    $('character_type_' + id).addClassName('selected');

    if($('description_character_type_' + id)){
      $('description_character_type_' + id).show();
    }
  }
}

var Mission = {
  onComplete: function(){}
}

var Fight = {
  hideVictim: function(id){
    if($('character_' + id)){
      $('character_' + id).hide();
    }
  },
  hideCauseRespond: function(id){
    if($('respond_fight_' + id)){
      $('respond_fight_' + id).hide();
    }
  }
}


var Inventory = {
  onPurchase: function(){}
}

var HelpRequest = {
  create: function(context_id, context_type){
    new Ajax.Request(root_url + "help_requests", {
      parameters: "context_id=" + context_id + "&context_type=" + context_type,
      method: "POST",
      "scrollToTop": false,
      "showSpinner": false
    });
  }
};

var BossFight = {
  hideReminder: function(id){
    if($('boss_fight_block')){
      $('boss_fight_block').removeChild($(id));

      if($('boss_fight_block').by_class('boss_fight').length == 0){
        $('boss_fight_block').hide();
      }
    }
  }
}