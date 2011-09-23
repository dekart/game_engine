class Chats
  extend FacebookSignedRequest
  
  def self.call(env)
    if match_data = env["PATH_INFO"].match(/^\/chats\/(\w+)/) and chat_id = match_data[1]
      request = Rack::Request.new(env)
      params = request.params
      
      if character = extract_character(request)
        if request.post?
          Chat.save_message(chat_id, character, params['chat_text'])
        end
        
        messages = Chat.messages(chat_id, params['last_message_id'])
        
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