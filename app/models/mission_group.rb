class MissionGroup < ActiveRecord::Base
  extend HasPayouts

  has_many :missions, :dependent => :destroy

  default_scope :order => "mission_groups.level"
  
  named_scope :next_for, Proc.new{|character|
    {
      :conditions => ["mission_groups.level > ?", character.level],
      :order      => "mission_groups.level"
    }
  }
  named_scope :before, Proc.new{|group|
    {
      :conditions => ["mission_groups.level < ?", group.level]
    }
  }
  named_scope :after, Proc.new{|group|
    {
      :conditions => ["mission_groups.level > ?", group.level]
    }
  }

  has_payouts

  validates_presence_of :name, :level
  validates_numericality_of :level, :allow_nil => true

  def previous_group
    self.class.before(self).first(:order => "mission_groups.level DESC")
  end

  def next_group
    self.class.after(self).first(:order => "mission_groups.level")
  end

  def locked?(character)
    character.level < self.level
  end
end
