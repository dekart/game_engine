class Character
  module AppRequests
    class Collection
      def initialize(character)
        @character = character
      end

      def all
        AppRequest::Base.for_character(@character).visible.includes(:sender => :user)
      end

      def count
        @total ||= Rails.cache.fetch(AppRequest::Base.cache_key(@character.user)) do
          all.count
        end
      end

      def as_json(*args)
        result = {
          :count => count,
          :requests => {}
        }

        stack_id = 0

        all.sort_by{|r| r.class.name }.each do |request|
          next unless acceptable?(request)

          if request.class.stackable?
            result[:requests][request.class.type_name] ||= {}

            if request.target
              stack_key = request.target
            else
              stack_key = request.class.name.hash + stack_id

              # Group requests by 10
              if result[:requests][request.class.type_name][stack_key] and
                  result[:requests][request.class.type_name][stack_key][:senders].size == 10
                stack_key += 1
                stack_id += 1
              end
            end

            result[:requests][request.class.type_name][stack_key] ||= {
              :target => request.target.as_json,
              :senders => []
            }

            result[:requests][request.class.type_name][stack_key][:senders] << request.sender.as_json_for_app_requests.merge(
              :request_id => request.id
            )
          else
            result[:requests][request.class.type_name] ||= []
            result[:requests][request.class.type_name] << request.sender.as_json_for_app_requests.merge(
              request.target ? {:target => request.target.as_json} : {}
            ).merge(
              :request_id => request.id
            )
          end
        end

        result[:requests].each do |type, requests|
          result[:requests][type] = requests.values if requests.is_a?(Hash)
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