(function($){
    // Chat
  var chatFnMethods = {
    init: function(updateTime) {
      var $chat = $(this);

      $chat.chat('loadMessages');

      Visibility.every(updateTime * 1000, function() {
        $chat.chat('loadMessages');
      });
    },

    lastMessageId: function() {
      var lastMessageId = "";
      if ($(this).find('.message').length > 0) {
        lastMessageId = $(this).find('.message:last').data('message-id');
      }
      return lastMessageId;
    },

    loadMessages: function() {
      var $chat = $(this);

      $.getJSON('/chats/' + $chat.data('chat-id'), {
          last_message_id: $chat.chat('lastMessageId')
        },
        function(data) {
          $chat.chat('processData', data);
      });
    },

    refreshOnlineList: function(charactersOnline) {
      var $chat = $(this);
      var $content = $(this).find(".online .content");

      if(!charactersOnline || charactersOnline.length == 0){
        $content.empty();

        return;
      }

      var $template = $("#online-characters-template");

      // currentCharacter always first
      var currentCharacter = charactersOnline.shift();

      var $characters = $content.find('.character');

      // first load
      if ($characters.length == 0) {
        $content.append($template.tmpl(currentCharacter));
      }

      var wasOnline = $characters.map(function() {
        var id = parseInt($(this).data('id'));

        if (currentCharacter.facebook_id != id){
          return id;
        }
      }).toArray();

      // add new users
      $.each(charactersOnline, function(index, character) {
        if ($.inArray(character.facebook_id, wasOnline) == -1) {
          $content.prepend($template.tmpl(character));
        }
      });

      // remove disconnected users
      var onlineFacebookIds = $.map(charactersOnline, function(e){ return e.facebook_id });
      $.each(wasOnline, function(index, facebookId) {
        if ($.inArray(facebookId, onlineFacebookIds) == -1) {
          $content.find(".character[data-id='" + facebookId + "']").remove();
        }
      });
    },

    appendMessages: function(messages) {
      if (messages && messages.length > 0) {
        var lastReceivedMessageId = $.parseJSON(messages[messages.length - 1]).id;
        var lastMessageId = $(this).chat('lastMessageId');

        // prevent double appending, when timer and send query happens
        if (lastReceivedMessageId != lastMessageId) {
          var $messages = $(this).find('.messages');

          for (var i = 0; i < messages.length; i++) {
            var message = $.parseJSON(messages[i]);
            var messageContent = $(this).chat('template').tmpl(message);

            $messages.append(messageContent);
          }

          $(this).find('.messages-container').scrollTop($messages.outerHeight());
        }
      }
    },

    template: function() {
      var templateId = $(this).data('template');
      return $('#' + templateId);
    },

    onSubmit: function() {
      var $chat = $(this).parent('.chat');

      var lastMessageId = $chat.chat('lastMessageId');

      var data = $(this).serializeArray();
      data.push({name: 'last_message_id', value: lastMessageId});

      $.post(
        $(this).attr('action'),
        $.param(data),
        function(data) {
          $chat.chat('processData', data);
        },
        'json'
      );

      var $chatText = $(this).find("[name='chat_text']");
      $chatText.val("");
      $chatText.trigger('change');
    },

    processData: function(data) {
      if(!data){
        return;
      }

      var $chat = $(this);

      $chat.chat('appendMessages', data.messages);
      $chat.chat('refreshOnlineList', data.characters_online);
    }
  };

  $.fn.chat = function(method) {
    if ( chatFnMethods[method] ) {
      return chatFnMethods[ method ].apply( this, Array.prototype.slice.call( arguments, 1 ));
    } else {
      $.error('Method ' +  method + ' does not exist on jQuery.chat');
    }
  }
})(jQuery);