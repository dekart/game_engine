class Mission < ActiveRecord::Base
  has_many :ranks

  named_scope :available_for, Proc.new {|character|
    { :conditions => ["level <= ?", character.level], :order => :level }
  }

  def completeness_for(character)
    self.ranks.find_or_initialize_by_character_id(character.id).win_count.to_f / self.win_amount * 100
  end

  def money
    @money ||= rand(self.money_max - self.money_min) + self.money_min
  end
end
