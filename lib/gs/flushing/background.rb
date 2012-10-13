module GS
  module Flushing
    module Background
      def setup_flushing
        @event_log = []

        start_worker
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

      def store_event(event)
        @lock.synchronize do
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

        persist_events(events) unless events.empty?
      end
    end
  end
end