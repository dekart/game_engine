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
    $("co_experience").setTextValue(a.character.experience);
    $("co_level").setTextValue(a.character.level);
    $("co_health").setTextValue(a.character.hp + "/" + a.character.health);
    $("co_energy").setTextValue(a.character.ep + "/" + a.character.energy);

    if(a.character.points > 0) {
      $("co_point_link").setTextValue("+" + a.character.points);
      $("co_points").show();
    }
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