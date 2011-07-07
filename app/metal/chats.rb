class Chats
  def self.call(env)
    if match_data = env["PATH_INFO"].match(/^\/chats\/(\w+)/) and chat_id = match_data[1]
      request = Rack::Request.new(env)
      params = request.params
      
      if request.post?
        Chat.save_message(chat_id, params['chat_character_id'], params['chat_text'])
        
        [200, {"Content-Type" => "application/json"}, Chat.messages(chat_id, params['last_message_id']).to_json]
      elsif request.get?
        [200, {"Content-Type" => "application/json"}, Chat.messages(chat_id, params['last_message_id']).to_json]
      end
    else
      [404, {"Content-Type" => "text/html"}, "Not Found"]
    end
  end
end