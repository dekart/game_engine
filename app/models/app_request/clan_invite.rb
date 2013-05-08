class AppRequest::ClanInvite < AppRequest::Base
  class << self
    def ids_to_exclude_for(character)
      Rails.cache.fetch(exclude_ids_cache_key(character), :expires_in => 15.minutes) do
        from_character(character).sent_after(Setting.i(:clan_repeat_invite_delay).days.ago).receiver_ids +

        ClanMember.all_clan_creators_facebook_ids +

        (character.clan ? character.clan.members_facebook_ids : [])
      end
    end

    def target_from_data(data)
      if data['target_type'] and data['target_id']
        Clan.find(data['target_id'])
      end
    end
  end

  def clan
    @clan ||= target || sender.clan
  end

  protected

  def after_process
    super

    if receiver && receiver.clan != clan && sender.clan_member.creator?
      sender.clan.clan_membership_invitations.create(:character => receiver)
    end
  end
end