class Mission < ActiveRecord::Base
  has_many :ranks do
    def for_character(character)
      self.find_or_initialize_by_character_id(character.id)
    end
  end

  named_scope :available_for, Proc.new {|character|
    { :conditions => ["level <= ?", character.level], :order => :level }
  }
end
