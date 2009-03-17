var Spinner = {
  hide: function(){
    $('spinner').setStyle({display: "none"});
  }
}

var Character = {
  update: function(a){
    $('character_basic_money').setTextValue(a.character.basic_money);
    $('character_vip_money').setTextValue(a.character.basic_money);
    $('character_experience').setTextValue(a.character.experience);
    $('character_level').setTextValue(a.character.level);
    $('character_health').setTextValue(a.character.hp + "/" + a.character.health);
    $('character_energy').setTextValue(a.character.ep + "/" + a.character.energy);

    if(a.character.points > 0) {
      $('character_points_link').setTextValue("+" + a.character.points);
      $('character_points').setStyle({display: "inline"});
    }
  }
}
