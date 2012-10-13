module GS
  module Backends
    module Redis
      def store_events(events)
        ::Redis.current.rpush('gamestats', *events.map{|e| Marshal.dump(e) })
      end
    end
  end
end