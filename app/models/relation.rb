class Relation < ActiveRecord::Base
  ATTRIBUTES = %w{level attack defence health energy stamina}

  belongs_to  :owner, :class_name => "Character", :counter_cache => true
  belongs_to  :character
  has_one     :assignment, :dependent => :destroy, :foreign_key => "relation_id"

  named_scope :not_assigned,
    :include    => [:assignment, :character],
    :conditions => "assignments.id IS NULL"
  named_scope :assigned,
    :include    => [:assignment, :character],
    :conditions => "assignments.id IS NOT NULL"
  
  #TODO Check size of the 'bag' placement when relation is getting removed
end
