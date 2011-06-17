class NotificationsController < ApplicationController
  def disable
    @notification = current_character.notifications.find(params[:id])

    @notification.disable

    render :text => "<!-- no data -->"
  end
  
  def settings
    @notifications = current_character.notifications
    
    render :layout => "ajax"
  end
  
  def update_settings
    if params[:notification] and notification_ids = params[:notification][:ids]
      notification_ids.collect! {|n| n.to_i}
      
      current_character.notifications.each do |notification|
        if notification_ids.include?(notification.id)
          notification.enable! if notification.disabled?
        else
          notification.disable!
        end
      end
    end
    
    render :layout => 'ajax'
  end
end
