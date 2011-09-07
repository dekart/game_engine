class Chat
  class << self
    def messages(chat_id, from_id = nil)
      messages = $redis.lrange(key(chat_id), 0, Setting.i(:chat_max_messages))
      
      if !from_id.blank? and index = messages.index {|m| ActiveSupport::JSON.decode(m)['id'] == from_id }
        messages = messages[index + 1 .. -1]
      end
      
      messages
    end
    
    def save_message(chat_id, character_id, text)
      return if chat_id.blank? || text.blank?
      
      character = Character.find(character_id, :joins => :user)
      
      message = {
        :id             => Digest::MD5.hexdigest("%s-%s" % [Time.now, character.id]),
        
        :facebook_id    => character.facebook_id,
        :name           => (character.name.present? ? character.name : character.user.first_name),
        :character_key  => character.key,
        
        :text           => text.mb_chars[0, Setting.i(:chat_max_length)].to_s,
        
        :created_at     => Time.now.to_s(:short)
      }
      
      $redis.multi do
        $redis.rpush(key(chat_id), message.to_json)
        $redis.ltrim(key(chat_id), - Setting.i(:chat_max_messages), -1)
      end
      
      message
    end
    
    def key(chat_id)
      "chat_#{chat_id}"
    end
  end
end