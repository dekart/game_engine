class AppRequest::ClanInvite < AppRequest::Base
  class << self
    def ids_to_exclude_for(character)
      Rails.cache.fetch(exclude_ids_cache_key(character), :expires_in => 1.minutes) do
        from_character(character).sent_after(Setting.i(:clan_repeat_invite_delay).days.ago).receiver_ids + (character.clan ? character.clan.members_facebook_ids : [])
      end
    end
  end
  
  protected
    
  def after_accept
    super

    if sender.clan_member.try(:creator?)
      receiver.clan_member.destroy if receiver.clan_member
      
      sender.clan.clan_members.create(:character => receiver, :role => :participant)
    else
      sender.clan.clan_membership_applications.create(:character => receiver)   
    end
  end
end