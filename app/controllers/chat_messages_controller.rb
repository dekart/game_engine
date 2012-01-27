class ChatMessagesController < ActionController::Metal
  def index
    facebook_user = Facepalm::User.from_signed_request(Facepalm::Config.default, request.env['HTTP_SIGNED_REQUEST'])
    chat_id = params[:chat_id]
  
    if facebook_user and character = User.find_by_facebook_id(facebook_user.uid).try(:character)
      if request.post?
        Chat.save_message(chat_id, character, request.params['chat_text'])
      end
    
      messages = Chat.messages(chat_id, request.params['last_message_id'])
    
      Chat.update_online_status(chat_id, character)
    
      online_characters = Chat.online_characters_for(chat_id, character)
      
      response = { 
        :messages => messages,
        :characters_online => online_characters
      }
    else
      response = {}
    end
    
    self.content_type = Mime::JSON
    self.response_body = response.to_json
  end
end