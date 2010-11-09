class Character
  module FriendRelations
    def character_ids
      all(:select => "character_id").collect{|r| r[:character_id] }
    end

    def facebook_ids
      all(:include => {:character => :user}).collect{|r|
        r.character.user.facebook_id
      }
    end

    def with(character)
      find(:first, :conditions => ['character_id = ?', character.id])
    end

    def established?(character)
      !with(character).nil?
    end

    def random
      first(:offset => rand(size)) if size > 0
    end
  end
end
