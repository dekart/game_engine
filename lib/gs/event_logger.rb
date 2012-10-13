module GS
  class EventLogger
    include GS::Backends::Redis

    def initialize
      @lock = Mutex.new
      @event_log = []
    end

    def start_worker
      @worker_thread = Thread.new do
        begin
          periodically_flush_events
        rescue Exception => e
          Rails.logger.error e
          Rails.logger.error e.backtrace.join("\n")
        end
      end
    end

    def log(*args)
      attributes = args.extract_options!
      type, label = args

      @lock.synchronize do
        event = {
          :time   => Time.now.to_i,
          :type   => type,
          :label  => label
        }

        attributes.each do |key, value|
          event[key.to_sym] = value if value != 0
        end

        @event_log << event
      end
    end

    def periodically_flush_events
      while true
        flush_events

        sleep(5)
      end
    end

    def flush_events
      events = []

      @lock.synchronize do
        @event_log.each do |e|
          events << e
        end

        @event_log.clear
      end

      store_events(events) unless events.empty?
    end
  end
end