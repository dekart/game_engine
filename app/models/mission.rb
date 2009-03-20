class Mission < ActiveRecord::Base
  has_many :ranks

  named_scope :available_for, Proc.new {|character|
    { :conditions => ["level <= ?", character.level], :order => :level }
  }

  def by(character)
    self.ranks.find_or_initialize_by_character_id(character.id)
  end

  def money
    @money ||= rand(self.money_max - self.money_min) + self.money_min
  end
end
