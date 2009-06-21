class MissionGroup < ActiveRecord::Base
  has_many :missions, :dependent => :nullify

  named_scope :next_for, Proc.new{|character|
    {
      :conditions => ["level > ?", character.level],
      :order      => :level
    }
  }
  validates_presence_of :name, :level
  validates_numericality_of :level, :allow_nil => true
end
