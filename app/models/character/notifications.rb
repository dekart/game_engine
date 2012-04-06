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

      def schedule(type, data = {})
        notification = list.detect{|notification| notification.type == type}
        data[:state] = notification ? notification.state : "pending"

        if notification.nil?
          notification = Notification::Base.type_to_class(type).new(proxy_association.owner, data.to_json)

          list << notification
        else
          notification.data = data
        end

        notification.schedule unless notification.disabled?

        true
      end

      def schedule_friends_to_invite
        friend_ids = proxy_association.owner.friend_filter.for_invitation(15)

        proxy_association.owner.notifications.schedule(:friends_to_invite, :friend_ids => friend_ids) unless friend_ids.empty?
      end

      def with_state(state)
        list.select{|notification| notification.state == state.to_s}
      end
    end
  end
end
