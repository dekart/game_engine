class AppRequest::MonsterInvite < AppRequest::Base
  # FIXME remove temporary support of old data keys
  def monster
    target || (Monster.find(data['monster_id']) if data && data['monster_id'])
  end
  
  protected
  
  def previous_similar_requests
    super.with_target(monster)
  end
  
  def later_similar_requests
    super.with_target(monster)
  end
  
  def after_accept
    super
    
    sender_monster_fight = sender.monster_fights.by_monster(monster)
    MonsterFight.increment_counter(:accepted_invites_count, sender_monster_fight)
    
    MonsterFight.create(:character => receiver, :monster => monster)
  end
end