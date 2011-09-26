class Chats
  class << self
    def call(env)
      if match_data = env["PATH_INFO"].match(/^\/chats\/(\w+)/) and chat_id = match_data[1]
        request = Rack::Request.new(env)
      
        facebook_user = Facepalm::User.from_signed_request(Facepalm::Config.default, request.env['HTTP_SIGNED_REQUEST'])
      
        if facebook_user and character = User.find_by_facebook_id(facebook_user.uid).try(:character)
          if request.post?
            Chat.save_message(chat_id, character, request.params['chat_text'])
          end
        
          messages = Chat.messages(chat_id, request.params['last_message_id'])
        
          Chat.update_online_status(chat_id, character)
        
          online_characters = Chat.online_characters_for(chat_id, character)
          
          [200, {"Content-Type" => "application/json"}, 
            { 
              :messages => messages,
              :characters_online => online_characters
            }.to_json]
        else
          [200, {"Content-Type" => "application/json"}, {}.to_json]
        end
      else
        [404, {"Content-Type" => "text/html"}, "Not Found"]
      end
    end
  end
end