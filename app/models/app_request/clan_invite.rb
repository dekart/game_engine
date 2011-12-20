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
end