var CharacterForm = {
  setup: function(){
    $('#character_types .character_type').click(function(){
      CharacterForm.set_character_type(this)
    });
  },

  set_character_type: function(selector){
    var $this = $(selector);

    $this.addClass('selected').
      siblings('.character_type').removeClass('selected');

    $('#character_character_type_id').val(
      $this.attr('value')
    );
  }
}

var Character = {
  update: function(a){
    $("#co_basic_money").text(a.character.formatted_basic_money);
    $("#co_vip_money").text(a.character.formatted_vip_money);
    $("#co_experience").text(a.character.experience + "/" + a.character.next_level_experience);
    $("#co_experience_percentage").css({width: a.character.level_progress_percentage + "%"})
    $("#co_level").text(a.character.level);
    $("#co_health").text(a.character.hp + "/" + a.character.health);
    $("#co_energy").text(a.character.ep + "/" + a.character.energy);
    $("#co_stamina").text(a.character.sp + "/" + a.character.stamina);

    if(a.character.points > 0) {
      $("#co_point_link").show();
    } else {
      $("#co_point_link").hide();
    }
    
    if(a.character.property_income > 0){
      Timer.start('#co_basic_money_timer', a.character.time_to_basic_money_restore, this.updateFromRemote);
    }
    Timer.start('#co_health_timer', a.character.time_to_hp_restore, this.updateFromRemote);
    Timer.start('#co_energy_timer', a.character.time_to_ep_restore, this.updateFromRemote);
    Timer.start('#co_stamina_timer', a.character.time_to_sp_restore, this.updateFromRemote);
  },

  upgrade_from_remote: function(){
    $.getJSON('/character_status', function(data){
      Character.update(data)
    });
  }
};

var Timer = {
  timers: {},

  format: function(value){
    var hours   = Math.floor(value / 3600);
    var minutes = Math.floor((value - hours * 3600) / 60);
    var seconds = value - hours * 3600 - minutes * 60;

    var result;
    if(hours > 0){
      result = hours + ":" + minutes;
    }else{
      result = minutes
    }

    if(seconds < 10){
      result = result + ":0" + seconds;
    }else{
      result = result + ":" + seconds;
    }

    return(result);
  },

  update: function(id){
    var element = $(id);

    if(element == null){
      this.timers[id].running = false;

      return
    }

    if(this.timers[id].value > 0){
      element.text(Timer.format(this.timers[id].value));

      this.timers[id].value = this.timers[id].value - 1;

      this.rerun(id);
    }else{
      element.text('');

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

$(function(){
  FB_RequireFeatures(['Base', 'Api', 'Common', 'XdComm', 'CanvasUtil', 'XFBML'], function() {
    FB.init(facebook_api_key,'/xd_receiver.html', {});
    
    FB.CanvasClient.setCanvasHeight($('body').height() + 'px')
  });
})