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
    $("#co .basic_money .value").text(a.character.formatted_basic_money);
    $("#co .vip_money .value").text(a.character.formatted_vip_money);
    $("#co .experience .value").text(a.character.experience + "/" + a.character.next_level_experience);
    $("#co .experience .percentage").css({width: a.character.level_progress_percentage + "%"})
    $("#co .level .value").text(a.character.level);
    $("#co .health .value").text(a.character.hp + "/" + a.character.health);
    $("#co .energy .value").text(a.character.ep + "/" + a.character.energy);
    $("#co .stamina .value").text(a.character.sp + "/" + a.character.stamina);

    if(a.character.points > 0) {
      $("#co .level .upgrade").show();
    } else {
      $("#co .level .upgrade").hide();
    }
    
    if(a.character.property_income > 0){
      Timer.start('#co .basic_money .timer', a.character.time_to_basic_money_restore, this.updateFromRemote);
    }
    Timer.start('#co .health .timer', a.character.time_to_hp_restore, this.updateFromRemote);
    Timer.start('#co .energy .timer', a.character.time_to_ep_restore, this.updateFromRemote);
    Timer.start('#co .stamina .timer', a.character.time_to_sp_restore, this.updateFromRemote);
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

var BossFight = {
  onWin: function(event, fight_id){
    BossFight.hide_reminder(fight_id);
  },
  
  onLose: function(event, fight_id){
    BossFight.hide_reminder(fight_id);
  },

  onExpire: function(event, fight_id){
    BossFight.hide_reminder(fight_id);
  },

  hide_reminder: function(fight_id){
    $('#boss_fight_' + fight_id).hide();

    $('#boss_fight_block:empty').hide();
  }
}

var AssignmentForm = {
  setup: function(){
    $('#new_assignment .tabs').tabs();

    $('#new_assignment .relations .relation').click(AssignmentForm.select_relation)
  },

  select_relation: function(){
    $('#new_assignment .relations .relation').removeClass('selected');

    var $this = $(this);

    $this.addClass('selected');

    $('#assignment_relation_id').val($this.attr('value'));
  }
}

var Spinner = {
  setup: function(){
    $('#spinner').
      ajaxStart(function(){
        Spinner.show();
      }).
      ajaxStop(function(){
        Spinner.hide();
      });
  },
  show: function(){
    $('#spinner').show();
    $('#spinner_field').focus();
  },
  hide: function(){
    $('#spinner').hide()
  }
}

$(function(){
  
  FB_RequireFeatures(['Base', 'Api', 'Common', 'XdComm', 'CanvasUtil', 'Connect', 'XFBML'], function(){
    FB.XdComm.Server.init("/xd_receiver.html");

    FB.CanvasClient.set_timerInterval(1)
    FB.CanvasClient.startTimerToSizeToContent();

    // Manually set canvas height to be sure that it will fit to content size
    FB.CanvasClient.setCanvasHeight($('body').outerHeight());

    FB.init(facebook_api_key, "/xd_receiver.html", {debugLogLevel: 2});

    FB.XFBML.Host.parseDomTree();
  })

  $(document).bind('result.received', function(){
    $(document).trigger('remote_content.received');

    $('#result').show();
  });

  $(document).bind('remote_content.received', function(){
    FB.XFBML.Host.parseDomTree();
  });

  Spinner.setup();
})