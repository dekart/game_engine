class AppRequest::Invitation < AppRequest::Base
  class << self
    def ids_to_exclude_for(character)
      Rails.cache.fetch(exclude_ids_cache_key(character), :expires_in => 15.minutes) do
        from_character(character).sent_after(Setting.i(:relation_repeat_invite_delay).days.ago).receiver_ids + character.friend_relations.facebook_ids
      end
    end
  end

  protected

  def after_accept
    super

    receiver.friend_relations.establish!(sender)

    AppRequest::Invitation.between(sender, receiver_id).each do |invitation|
      invitation.ignore
    end
  end
end