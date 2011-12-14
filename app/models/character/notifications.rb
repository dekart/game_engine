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
      def schedule(type, data = nil)
        if existing = by_type(type).first
          existing.transaction do
            existing.update_attributes(:data => data)

            existing.schedule if existing.displayed?
          end
        else
          klass = Notification::Base.type_to_class(type)

          self << klass.new(:data => data)
        end
        
        true
      end
      
      def schedule_friends_to_invite
        friend_ids = proxy_owner.friend_filter.for_invitation(15)
        
        if friend_ids.any? && proxy_owner.notifications.by_type(:friends_to_invite).empty?
          proxy_owner.notifications.schedule(:friends_to_invite, :friend_ids => friend_ids)
        end
      end
    end
  end
end
