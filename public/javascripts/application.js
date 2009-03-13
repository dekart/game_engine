var Spinner = {
  hide: function(){
    $('spinner').setStyle({display: "none"});
  }
}

var Character = {
  update: function(a){
    $('character_money').setTextValue(a.character.money);
    $('character_experience').setTextValue(a.character.experience);
    $('character_level').setTextValue(a.character.level);
    $('character_health').setTextValue(a.character.hp + "/" + a.character.health);
    $('character_energy').setTextValue(a.character.ep + "/" + a.character.energy);

    if(a.character.points > 0) {
      $('character_points_link').setTextValue("+" + a.character.points + " points");
      $('character_points').setStyle({display: "inline"});
    }
  }
}
