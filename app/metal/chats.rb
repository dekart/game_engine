class Chats
  def self.call(env)
    if match_data = env["PATH_INFO"].match(/^\/chats\/(\w+)/) and chat_id = match_data[1]
      request = Rack::Request.new(env)
      params = request.params
      
      # TODO: extract user_id from signed request
      character_id = params['chat_character_id']
      
      if request.post?
        Chat.save_message(chat_id, character_id, params['chat_text'])
      end
      
      messages = Chat.messages(chat_id, params['last_message_id'])
      
      Chat.update_online_status(chat_id, character_id)
      
      online_characters = Chat.online_characters_for(chat_id, character_id)
        
      [200, {"Content-Type" => "application/json"}, 
        { 
          :messages => messages,
          :characters_online => online_characters
        }.to_json]
    else
      [404, {"Content-Type" => "text/html"}, "Not Found"]
    end
  end
end