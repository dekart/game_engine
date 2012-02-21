class NotificationsController < ApplicationController
  def disable
    @notification = current_character.notifications.list.detect{|notification| notification.type == params[:type].to_sym }

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
