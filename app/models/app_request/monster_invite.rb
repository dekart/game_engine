class AppRequest::MonsterInvite < AppRequest::Base
  def monster
    target
  end

  protected

  def previous_similar_requests
    super.with_target(monster)
  end

  def later_similar_requests
    super.with_target(monster)
  end
end