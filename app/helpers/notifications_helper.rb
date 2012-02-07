module NotificationsHelper
  def display_notifications
    if notifications = current_character.notifications.with_state(:pending).all and notifications.any?
      Notification::Base.transaction do
        notifications.each do |n|
          n.display_notification
        end
      end

      notifications.collect do |notification|
        render("notifications/#{notification.class_to_type}", :notification => notification)
        
        dom_ready do
          ga_track_event("Notifications", "Show", notification.title)
        end
      end.join.html_safe
    end
  end
end
