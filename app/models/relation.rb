class Relation < ActiveRecord::Base
  belongs_to :source_character, :foreign_key => "source_id", :class_name => "Character", :counter_cache => true
  belongs_to :target_character, :foreign_key => "target_id", :class_name => "Character"
  has_one :assignment

  named_scope :not_assigned,
    :include    => [:assignment, :target_character],
    :conditions => "assignments.id IS NULL"
  named_scope :assigned, 
    :include    => [:assignment, :target_character],
    :conditions => "assignments.id IS NOT NULL"

  validates_uniqueness_of :target_id, :scope => :source_id

  def self.destroy_between(c1, c2)
    self.transaction do
      Relation.find(:all,
        :conditions => [
          "(source_id = :c1 AND target_id = :c2) OR (source_id = :c2 AND target_id = :c1)",
          {
            :c1 => c1,
            :c2 => c2
          }
        ]
      ).each do |relation|
        relation.destroy
      end

      Invitation.find(:all, :conditions => [
          "(sender_id = :c1 AND receiver_id = :u2) OR (sender_id = :c2 AND receiver_id = :u1)",
          {
            :c1 => c1,
            :c2 => c2,
            :u1 => c1.user.facebook_id,
            :u2 => c2.user.facebook_id
          }
        ]
      ).each do |invitation|
        invitation.destroy
      end
    end
  end
end
