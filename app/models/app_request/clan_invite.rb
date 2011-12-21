class AppRequest::ClanInvite < AppRequest::Base
  class << self
    def ids_to_exclude_for(character)
      ids = Rails.cache.fetch(exclude_ids_cache_key(character), :expires_in => 15.minutes) do
              from_character(character).sent_after(Setting.i(:clan_repeat_invite_delay).days.ago).receiver_ids
            end
      
      ids += character.clan.members_facebook_ids if character.clan
      ids += ClanMember.all_clan_creators_facebook_ids
    end
  end
  
  protected
  
  def after_process
    super
    
    if receiver.clan != sender.clan && sender.clan_member.creator? && !receiver.clan_membership_relations.invited_to_join?(sender.clan)
      sender.clan.clan_membership_relations.create(:character => receiver)
    end
  end
  
  def after_accept
    super
    
    if receiver.clan_membership_applications.declared_to_join?(sender.clan)
      sender.clan.create_member_at_invitation!(receiver)
    end
  end
  
  def after_ignore
    super
    
    receiver.clan_membership_relations.delete_invitation_to_join!(sender.clan)
  end
end