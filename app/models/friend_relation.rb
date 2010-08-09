class FriendRelation < Relation
  delegate(
    *(ATTRIBUTES + [:to => :character])
  )

  validates_uniqueness_of :character_id, :scope => :owner_id

  def self.destroy_between(c1, c2)
    transaction do
      Relation.find(:all,
        :conditions => [
          "(owner_id = :c1 AND character_id = :c2) OR (owner_id = :c2 AND character_id = :c1)",
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
