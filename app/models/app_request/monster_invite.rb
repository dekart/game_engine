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
end