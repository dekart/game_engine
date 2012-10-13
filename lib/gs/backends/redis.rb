module GS
  module Backends
    module Redis
      def persist_events(events)
        ::Redis.current.rpush('gamestats', *events.map{|e| Marshal.dump(e) })
      end
    end
  end
end