class LoggedEvent < ActiveRecord::Base
  #belongs_to :character

  def reference=(value)
    case value
    when ActiveRecord::Base
      self.reference_id   = value.id
      self.reference_type = value.class.sti_name
    when Array
      self.reference_type = value.first.to_s
      self.reference_id   = value.last
    else
      self.reference_type = value.to_s
    end
  end

  def reference
    klass = reference_type.constantize

    klass.find_by_id(reference_id)
  rescue NameError
    reference_type
  end
  
  def csv_line
    [
      self.occurred_at.strftime("%d-%m-%Y %H:%M"), 
      self.character_id, 
      self.basic_money || 0, 
      self.vip_money || 0, 
      self.health || 0, 
      self.energy || 0, 
      self.stamina || 0, 
      self.experience || 0, 
      self.string_value, 
      self.event_type
    ].join(',')
  end
end
