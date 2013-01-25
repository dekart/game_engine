class AppRequest::MonsterInvite < AppRequest::Base
  class << self
    def stackable?
      true
    end

    def target_from_data(data)
      if data['target_type'] and data['target_id']
        Monster.find(data['target_id'])
      end
    end
  end

  def monster
    target
  end

  def correct?
    target.is_a?(Monster) && target.progress?
  end

  protected

  def previous_similar_requests
    super.with_target(monster)
  end

  def later_similar_requests
    super.with_target(monster)
  end
end