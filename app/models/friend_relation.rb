class FriendRelation < Relation
  delegate(
    *(ATTRIBUTES + [:to => :character])
  )

  validates_uniqueness_of :character_id, :scope => :owner_id

  def self.destroy_between(c1, c2)
    transaction do
      Relation.scoped(
        :conditions => [
          "(owner_id = :c1 AND character_id = :c2) OR (owner_id = :c2 AND character_id = :c1)",
          {
            :c1 => c1,
            :c2 => c2
          }
        ]
      ).destroy_all
    end
  end

  def name
    character.nickname(true)
  end

  def as_json_for_assignment(*args)
    super(*args).merge(:facebook_id => character.facebook_id)
  end
end
