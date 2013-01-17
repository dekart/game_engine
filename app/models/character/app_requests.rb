class Character
  module AppRequests
    class Collection
      def initialize(character)
        @character = character
      end

      def all
        AppRequest::Base.for_character(@character).visible.includes(:sender => :user)
      end

      def as_json(*args)
        result = {}

        all.each do |request|
          next unless acceptable?(request)

          if request.class.stackable?
            result[request.class.type_name] ||= {}
            result[request.class.type_name][request.target] ||= {
              :target => request.target.as_json,
              :senders => []
            }

            result[request.class.type_name][request.target][:senders] << request.sender.as_json_for_app_requests.merge(
              :request_id => request.id
            )
          else
            result[request.class.type_name] ||= []
            result[request.class.type_name] << request.sender.as_json_for_app_requests.merge(
              request.target ? {:target => request.target.as_json} : {}
            ).merge(
              :request_id => request.id
            )
          end
        end

        result.each do |type, requests|
          result[type] = requests.values if requests.is_a?(Hash)
        end

        result
      end

      def acceptable?(request)
        if request.is_a?(AppRequest::Gift)
          @gift_recent_accepts ||= AppRequest::Gift.recent_accepts(@character)

          !@gift_recent_accepts.include?(request.sender.id)
        else
          true
        end
      end
    end

    def app_requests
      @app_requests ||= Character::AppRequests::Collection.new(self)
    end
  end
end