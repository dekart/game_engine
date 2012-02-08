class NotificationsController < ApplicationController
  def disable
    @notification = current_character.notifications.find(params[:id])

    @notification.disable
  end
  
  def settings
    @notifications = current_character.notifications
  end
  
  def update_settings
    if params[:notification] && params[:notification][:ids]
      notification_ids = params[:notification][:ids]
      notification_ids.collect! {|n| n.to_i}
    else
      notification_ids = []
    end
    
    current_character.notifications.each do |notification|
      if notification_ids.include?(notification.id)
        notification.enable! if notification.disabled?
      else
        notification.disable!
      end
    end
  end
end
