class Chat
  class << self
    def messages(chat_id, from_id = nil)
      messages = $redis.lrange(self.key(chat_id), 0, Setting.i(:chat_max_messages))
      
      if from_id
        index = messages.index {|m| ActiveSupport::JSON.decode(m)['id'] == from_id}
        messages = messages[index + 1..messages.length] if index
      end
      
      messages
    end
    
    def save_message(chat_id, character_id, text)
      character = Character.find(character_id, :joins => :user)
      
      time = Time.now
      
      message = {
        :id =>  Digest::MD5.hexdigest("%s-%s" % [time, character.id]),
        :facebook_id => character.user.facebook_id,
        :text => text,
        :created_at => time,
        :name => character.name,
        :character_key => character.key
      }
      
      $redis.multi do
        $redis.rpush(self.key(chat_id), message.to_json)
        $redis.ltrim(self.key(chat_id), 0, Setting.i(:chat_max_messages))
      end
      
      message
    end
    
    def key(chat_id)
      "chat_#{chat_id}"
    end
  end
end