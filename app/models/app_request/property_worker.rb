class AppRequest::PropertyWorker < AppRequest::Base
  class << self
    def ids_to_exclude_for(character)
      Rails.cache.fetch(exclude_ids_cache_key(character), :expires_in => 15.minutes) do
        from_character(character).sent_after(Setting.i(:property_worker_hire_delay).hours.ago).receiver_ids
      end
    end

    def target_from_data(data)
      if data['target_type'] and data['target_id']
        Property.find(data['target_id'])
      end
    end
  end

  protected

  def previous_similar_requests
    super.with_target(target)
  end

  def later_similar_requests
    super.with_target(target)
  end

  def after_accept
    super

    target.add_worker!(receiver)
  end
end