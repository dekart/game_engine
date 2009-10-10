class MissionGroup < ActiveRecord::Base
  extend HasPayouts

  has_many :missions, :dependent => :destroy
  has_many :mission_group_ranks, :dependent => :delete_all

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

  acts_as_dropdown :text => "name_with_level", :order => "level"

  has_attached_file :image

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

  def name_with_level
    "%s (%s %s)" % [name, Character.human_attribute_name("level"), level]
  end
end
