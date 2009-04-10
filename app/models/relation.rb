class Relation < ActiveRecord::Base
  belongs_to :source, :class_name => "Character"
  belongs_to :target, :class_name => "Character"

  validates_uniqueness_of :target_id, :scope => :source_id
end
