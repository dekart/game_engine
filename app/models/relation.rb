class Relation < ActiveRecord::Base
  ATTRIBUTES = %w{level attack defence health energy stamina}

  belongs_to  :owner, :class_name => "Character"
  belongs_to  :character
  has_one     :assignment, :dependent => :destroy, :foreign_key => "relation_id"

  scope :available,
    :include    => [:assignment, :character],
    :conditions => "assignments.id IS NULL"
  scope :assigned,
    :include    => [:assignment, :character],
    :conditions => "assignments.id IS NOT NULL"
  scope :not_banned, Proc.new{
    {
      :include    => :character,
      :conditions => ["characters.id IS NULL OR characters.id NOT IN(?)", Character.banned_ids]
    }
  }

  #TODO Check size of the 'bag' placement when relation is getting removed

  after_create  :increment_owner_relations_counter
  after_destroy :decrement_owner_relations_counter

  def as_json_for_assignment(assignment)
    {
      :type   => self.class.name.underscore,
      :id     => id,
      :name   => name,
      :level  => level,
      :effect => effect(assignment)
    }
  end

  def effect(assignment)
    Assignment.effect_value(assignment.context, self, assignment.role)
  end

  protected

  def increment_owner_relations_counter
    Character.update_counters(owner_id, :relations_count => 1)
  end

  def decrement_owner_relations_counter
    Character.update_counters(owner_id, :relations_count => -1)
  end
end
