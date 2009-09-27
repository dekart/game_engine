class Character
  module FriendRelations
    def facebook_ids
      find(:all, :include => {:target_character => :user}).collect{|r| r.target_character.user.facebook_id}
    end

    def with(character)
      find(:first, :conditions => ['target_id = ?', character.id])
    end

    def established?(character)
      !with(character).nil?
    end
  end
end