class Chat
  class << self
    def messages(chat_id, from_id = nil)
      messages = $redis.lrange(self.key(chat_id), 0, Setting.i(:chat_max_messages))
      
      unless from_id.blank?
        index = messages.index {|m| ActiveSupport::JSON.decode(m)['id'] == from_id}
        messages = messages[index + 1..messages.length] if index
      end
      
      messages
    end
    
    def save_message(chat_id, character_id, text)
      unless chat_id.blank? || text.blank?
        character = Character.find(character_id, :joins => :user)
        
        text = text[0, Setting.i(:chat_max_length)]
        
        message = {
          :id =>  Digest::MD5.hexdigest("%s-%s" % [Time.now, character.id]),
          :facebook_id => character.user.facebook_id,
          :text => text,
          :created_at => Time.now.strftime("%m.%d.%y %H:%M:%S"),
          :name => character.name,
          :character_key => character.key
        }
        
        $redis.multi do
          $redis.rpush(self.key(chat_id), message.to_json)
          $redis.ltrim(self.key(chat_id), -Setting.i(:chat_max_messages), -1)
        end
        
        message
      end
    end
    
    def key(chat_id)
      "chat_#{chat_id}"
    end
  end
end