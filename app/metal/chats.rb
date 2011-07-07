class Chats
  def self.call(env)
    if match_data = env["PATH_INFO"].match(/^\/chats\/(\w+)/) and chat_id = match_data[1]
      request = Rack::Request.new(env)
      params = request.params
      
      if request.post?
        message = Chat.save_message(chat_id, params['character_id'], params['text'])
        
        [200, {"Content-Type" => "application/json"}, message.to_json]
      elsif request.get?
        [200, {"Content-Type" => "application/json"}, Chat.messages(chat_id, params['from_id']).to_json]
      end
    else
      [404, {"Content-Type" => "text/html"}, "Not Found"]
    end
  end
end