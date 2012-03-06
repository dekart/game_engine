class Message < ActiveRecord::Base
  validates_presence_of :content, :min_level
  validates_numericality_of :min_level
  
  state_machine :initial => :pending do
    state :sending
    state :sent
    state :deleted

    event :start_sending do
      transition :pending => :sending
    end
    
    event :mark_sent do
      transition :sending => :sent
    end
    
    event :mark_deleted do
      transition :pending => :deleted
    end
    
    after_transition :on => :start_sending do |message|
      message.send(:schedule_mass_notification)
    end
  end
  
  def schedule_mass_notification
    Delayed::Job.enqueue Jobs::MassNotify.new(self.id)
  end
  
  def mass_notify(characters)
    transaction do   
      characters.each do |character|
        send_to(character)
      end
      
      self.last_recipient_id = characters.last.id
      self.amount_sent += characters.size
      
      save!
    end
  end
  
  def send_to(character)
    character.notifications.schedule(:information, :message_id => id)
  end
end
