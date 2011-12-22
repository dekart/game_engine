class AppRequest::ClanInvite < AppRequest::Base
  class << self
    def ids_to_exclude_for(character)
      Rails.cache.fetch(exclude_ids_cache_key(character), :expires_in => 15.minutes) do
        from_character(character).sent_after(Setting.i(:clan_repeat_invite_delay).days.ago).receiver_ids + ClanMember.all_clan_creators_facebook_ids + (character.clan ? character.clan.members_facebook_ids : [])
      end
    end
  end
  
  protected
  
  def after_process
    super
    
    if receiver.clan != sender.clan && sender.clan_member.creator?
      sender.clan.clan_membership_invitations.create(:character => receiver)
    end
  end
  
  def after_accept
    super
    
    if receiver.clan_membership_applications.asked_to_join?(sender.clan)
      receiver.clan_membership_invitations.invitation_to_join(sender.clan).try(:accept!)
    end
  end
  
  def after_ignore
    super
    
    receiver.clan_membership_invitations.invitation_to_join(sender.clan).try(:destroy)
  end
end