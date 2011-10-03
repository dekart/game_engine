class Chat
  class << self
    def messages(chat_id, from_id = nil)
      messages = $redis.lrange(key(chat_id), 0, Setting.i(:chat_max_messages))
      
      if !from_id.blank? and index = messages.index {|m| ActiveSupport::JSON.decode(m)['id'] == from_id }
        messages = messages[index + 1 .. -1]
      end
      
      messages
    end
    
    def save_message(chat_id, character, text)
      return if chat_id.blank? || text.blank?
      
      message = {
        :id             => Digest::MD5.hexdigest("%s-%s" % [Time.now, character.id]),
        
        :facebook_id    => character.user.facebook_id,
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
    
    def online_characters_for(chat_id, current_character)
      online_characters = []
      
      expire_online(chat_id)
      
      character_ids = $redis.zrange(online_characters_key(chat_id), 0, -1).map {|c| c.to_i}
      
      # current character always first
      online_characters << online_character_data(current_character)
      
      character_ids.each do |character_id|
        if character_id != current_character.id
          character = Character.find(character_id)
          
          online_characters << online_character_data(character, current_character)
        end
      end
      
      online_characters
    end
    
    def online_count(chat_id)
      expire_online(chat_id)
      
      $redis.zcard(online_characters_key(chat_id))
    end
    
    def key(chat_id)
      "chat_#{chat_id}"
    end
    
    def update_online_status(chat_id, character)
      $redis.zadd(online_characters_key(chat_id), Time.now.to_i, character.id)
    end
    
    protected
      
      def online_characters_key(chat_id)
        "online_characters_chat_#{chat_id}"
      end
      
      def online_character_data(character, current_character = nil)
        {
          :character_key  => character.key,
          :name => (character.name.present? ? character.name : character.user.first_name),
          :facebook_id    => character.facebook_id,
          :level => character.level,
          :friend => current_character && character.friend_relations.established?(current_character)
        }
      end
      
      def expire_online(chat_id)
        key = online_characters_key(chat_id)
        expired_time = (Time.now - Setting.i(:chat_online_users_expiration_time)).to_i
        
        $redis.zremrangebyscore(key, 0, expired_time)
      end
  end
end