module Jobs
  class MassNotify < Struct.new(:message_id)
    def perform
      
      if message = Message.find_by_id(message_id)
        characters = Character.all(
          :conditions => ["id > ?", message.last_recipient_id || 0], 
          :limit => 100
        )
          
        if !characters.empty?
          message.mass_notify(characters)
          
          message.schedule_mass_notification
        else
          message.mark_sent
        end
      end
      
    end
  end
end
