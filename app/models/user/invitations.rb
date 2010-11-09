class User
  module Invitations
    def facebook_ids
      all(:select => "invitations.receiver_id").collect{|i| i[:receiver_id].to_i }
    end

    def exclude_ids
      (facebook_ids + proxy_owner.character.friend_relations.facebook_ids).tap do |result|
        result.uniq!
      end
    end
  end
end
