class Character
  module Notifications
    def self.included(base)
      base.class_eval do
        has_many :notifications,
          :class_name => "Notification::Base",
          :extend     => AssociationExtension
      end
    end

    module AssociationExtension
      def fetch
        [].tap do |result|
          $redis.hgetall("notifications_#{proxy_association.owner.id}").each do |type, data|
            n = Notification::Base.type_to_class(type).new(proxy_association.owner, data)

            $redis.hdel("notifications_#{proxy_association.owner.id}", type) unless n.mark_read_manually

            result << n
          end
        end
      end

      def find_by_type(type)
        data = $redis.hget("notifications_#{proxy_association.owner.id}", type)

        Notification::Base.type_to_class(type).new(proxy_association.owner, data)
      end

      def count
        $redis.hlen("notifications_#{proxy_association.owner.id}")
      end

      def disabled_types
        $redis.smembers("disabled_notifications_#{proxy_association.owner.id}")
      end

      def enable_type(type)
        $redis.srem("disabled_notifications_#{ proxy_association.owner.id }", type)
      end

      def disable_type(type)
        $redis.hdel("notifications_#{ proxy_association.owner.id }", type)
  
        $redis.sadd("disabled_notifications_#{ proxy_association.owner.id }", type)
      end

      def schedule(type, data = {})
        if !disabled_types.include?(type.to_s)        
          notification = Notification::Base.type_to_class(type).new(proxy_association.owner, data.to_json)

          notification.enable
        end

        true
      end

      def schedule_friends_to_invite
        friend_ids = proxy_association.owner.friend_filter.for_invitation(15)

        proxy_association.owner.notifications.schedule(:friends_to_invite, :friend_ids => friend_ids) unless friend_ids.empty?
      end
    end
  end
end
