class AppRequest::Invitation < AppRequest::Base
  class << self
    def ids_to_exclude_for(character)
      from(character).sent_recently.receiver_ids + character.friend_relations.facebook_ids
    end
  end
  
  protected
  
  def after_accept
    super

    receiver.friend_relations.establish!(sender)
    
    AppRequest::Invitation.between(sender, receiver).each do |invitation|
      invitation.ignore
    end
  end
end