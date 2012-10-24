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
      def list
        @notifications ||= [].tap do |result|
          $redis.hgetall("notifications_#{proxy_association.owner.id}").each do |type, data|
            noti = Notification::Base.type_to_class(type).new(proxy_association.owner, data)

            result << noti
          end
        end
      end

      def count
        $redis.hgetall("notifications_#{proxy_association.owner.id}").size
      end

      def disabled_types
        $redis.smembers("disabled_notifications_#{proxy_association.owner.id}")
      end

      def schedule(type, data = {})
        if !disabled_types.include?(type.to_s)        
          notification = Notification::Base.type_to_class(type).new(proxy_association.owner, data.to_json)

          notification.enable

          list << notification
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
