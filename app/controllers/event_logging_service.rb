class EventLoggingService

  def self.log_event(type, data)
    $redis.rpush(type, data)
  end

end
