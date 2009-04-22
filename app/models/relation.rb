class Relation < ActiveRecord::Base
  belongs_to :source, :class_name => "Character"
  belongs_to :target, :class_name => "Character"

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
