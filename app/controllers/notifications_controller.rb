class NotificationsController < ApplicationController
  def index
    @notifications = current_character.notifications.with_state(:pending)

    @notifications.each do |n|
      n.mark_read unless n.mark_read_manually
    end

    respond_to do |format|
      format.js { render :layout => false }
    end
  end

  def mark_read
    @notification = current_character.notifications.list.detect{|notification| notification.type == params[:type].to_sym }

    @notification.mark_read
  end

  def disable
    @notification = current_character.notifications.list.detect{|notification| notification.type == params[:type].to_sym }

    @notification.disable
  end
  
  def settings
    @notifications = current_character.notifications.list
  end
  
  def update_settings
    if params[:notification] && params[:notification][:types]
      notification_types = params[:notification][:types]
    else
      notification_types = []
    end
    
    current_character.notifications.list.each do |notification|
      if notification_types.include?(notification.type.to_s)
        notification.enable! if notification.disabled?
      else
        notification.disable!
      end
    end
  end
end
