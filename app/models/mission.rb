class Mission < ActiveRecord::Base
  has_many :ranks

  named_scope :available_for, Proc.new {|character|
    { :conditions => ["level <= ?", character.level], :order => :level }
  }

  extend SerializeRequirements
  serialize_requirements :requirements
end
