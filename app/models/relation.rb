class Relation < ActiveRecord::Base
  ATTRIBUTES = %w{level attack defence health energy stamina}

  belongs_to  :source_character, :foreign_key => "source_id", :class_name => "Character", :counter_cache => true
  belongs_to  :target, :class_name => "Character"
  has_one     :assignment, :dependent => :destroy, :foreign_key => "relation_id"

  named_scope :not_assigned,
    :include    => [:assignment, :target],
    :conditions => "assignments.id IS NULL"
  named_scope :assigned,
    :include    => [:assignment, :target],
    :conditions => "assignments.id IS NOT NULL"
  
  #TODO Check size of the 'bag' placement when relation is getting removed
end
