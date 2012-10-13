module GS
  module Flushing
    module Immediate
      def setup_flushing
        #nothing to do here
      end

      def store_event(event)
        persist_events([event])
      end
    end
  end
end