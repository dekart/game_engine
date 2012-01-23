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
        friend_ids = proxy_association.owner.friend_filter.for_invitation(15)
        
        proxy_association.owner.notifications.schedule(:friends_to_invite, :friend_ids => friend_ids) unless friend_ids.empty?
      end
    end
  end
end
