module GS
  module Backends
    module Network
      BACKEND_URI = URI("http://localhost:3000/events")

      def store_events(events)
        request = Net::HTTP::Post.new(BACKEND_URI.path)
        request.set_form_data('events' => Yajl::Encoder.encode(events))

        Net::HTTP.start(BACKEND_URI.hostname, BACKEND_URI.port) do |http|
          http.request(request)
        end
      end
    end
  end
end