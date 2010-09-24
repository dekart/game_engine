class MissionGroup < ActiveRecord::Base
  extend HasPayouts
  extend HasRequirements

  has_many :missions, :dependent => :destroy
  has_many :bosses, :dependent => :destroy
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

  state_machine :initial => :hidden do
    state :hidden
    state :visible
    state :deleted

    event :publish do
      transition :hidden => :visible
    end

    event :hide do
      transition :visible => :hidden
    end

    event :mark_deleted do
      transition(any - [:deleted] => :deleted)
    end

    after_transition :to => :deleted do |group|
      group.delete_children!
    end
  end

  has_attached_file :image

  has_requirements
  has_payouts :complete

  validates_presence_of :name, :level
  validates_numericality_of :level, :allow_nil => true

  def self.to_dropdown(*args)
    without_state(:deleted).all(:order => :level).to_dropdown(*(args.any? ? args : "name_with_level"))
  end

  def previous_group
    self.class.with_state(:visible).before(self).first(:order => "mission_groups.level DESC")
  end

  def next_group
    self.class.with_state(:visible).after(self).first(:order => "mission_groups.level")
  end

  def available_for(character)
    enough_level?(character) && requirements.satisfies?(character)
  end

  def enough_level?(character)
    character.level >= level
  end

  def name_with_level
    "%s (%s %s)" % [name, Character.human_attribute_name("level"), level]
  end

  def delete_children!
    missions.without_state(:deleted).all.map{|m| m.mark_deleted }
    bosses.without_state(:deleted).all.map{|b| b.mark_deleted }
  end
end
