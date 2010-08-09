class Character
  module FriendRelations
    def character_ids
      all(:select => "target_id").collect{|r| r[:target_id] }
    end

    def facebook_ids
      all(:include => {:target => :user}).collect{|r| 
        r.target.user.facebook_id
      }
    end

    def with(character)
      find(:first, :conditions => ['target_id = ?', character.id])
    end

    def established?(character)
      !with(character).nil?
    end

    def random
      first(:offset => rand(size)) if size > 0
    end
  end
end