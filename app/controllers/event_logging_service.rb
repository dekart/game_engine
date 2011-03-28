class EventLoggingService
  def self.log_event(data)
    $redis.lpush(:logged_events, data)
  end

  def self.get_next_batch(size)
    $redis.lrange(:logged_events, 0, size - 1)
  end

  def self.trim_event_list(size)
    $redis.ltrim(:logged_events, size, -1)
  end

  def self.empty_event_list?
    $redis.llen(:logged_events) == 0
  end
end
