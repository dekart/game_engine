class Statistics
  class Sociality < self
    def reference_types
      result = User.all(
        :select => "reference, count(*) as total_amount",
        :group  => :reference,
        :order  => :reference
      )

      result.collect!{|d| [d[:reference], d[:total_amount].to_i] }

      result
    end

    def average_friends_by_reference(reference)
      User.where("users.reference = ?", reference).sum{|u| u.friend_ids.size }
    end

    def average_in_game_friends_by_reference(reference)
      character_ids = Character.joins(:user).where("users.reference = ?", reference).collect{|c| c.id }

      FriendRelation.where("owner_id IN (?)",character_ids).count
    end

    def average_referrers_by_reference(reference)
      user_ids = User.where("reference = ?", reference).collect{|u| u.id }

      User.where("referrer_id IN (?)", user_ids).count
    end
  end
end