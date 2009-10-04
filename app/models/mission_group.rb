class MissionGroup < ActiveRecord::Base
  extend HasPayouts

  has_many :missions, :dependent => :destroy

  named_scope :next_for, Proc.new{|character|
    {
      :conditions => ["mission_groups.level > ?", character.level],
      :order      => "mission_groups.level"
    }
  }

  has_payouts

  validates_presence_of :name, :level
  validates_numericality_of :level, :allow_nil => true
end
