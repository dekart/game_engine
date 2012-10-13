require 'net/http'

module GS
  def self.log(*args)
    event_logger.log(*args)
  end

  def self.event_logger
    @@event_logger ||= EventLogger.new.tap do |l|
      l.setup_flushing
    end
  end
end