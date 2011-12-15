class ApplicationController
  module Notifications
    include TutorialsHelper
    
    def self.included(base)
      base.class_eval do
        before_filter :show_notifications
      end
    end
    
    protected
    
    def show_notifications
      if current_user && !tutorial_visible?
        visits = Statistics::Visits.visited_by_user(current_user)
        
        if visits == Setting.i(:notifications_friends_to_invite_show_requests_count)
          current_character.notifications.schedule_friends_to_invite
        end
        
        if visits == Setting.i(:notifications_send_gift_show_requests_count)
          current_character.notifications.schedule(:send_gift)
        end
      end
    end
  end
end