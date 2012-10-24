class NotificationsController < ApplicationController
  def index
    @notifications = current_character.notifications.list

    @notifications.each do |n|
      n.delete unless n.mark_read_manually
    end

    respond_to do |format|
      format.js { render :layout => false }
    end
  end

  def mark_read
    @notification = current_character.notifications.list.detect{|notification| notification.type == params[:type].to_sym }

    @notification.delete
  end

  def disable
    @notification = Notification::Base.type_to_class(params[:type].to_sym).new(current_character)

    @notification.disable
  end
  
  def settings
    @notification_types = Notification::Base::TYPES

    @disabled_notifications = current_character.notifications.disabled_types
  end
  
  def update_settings
    if params[:notification] && params[:notification][:types]
      notification_types = params[:notification][:types]
    else
      notification_types = []
    end

    Notification::Base::TYPES.each do |type|
      type_name = type.class_to_type_name

      if notification_types.include?(type.name)
        $redis.srem("disabled_notifications_#{ current_character.id }", type_name)
      else
        $redis.hdel("notifications_#{ current_character.id }", type_name)
  
        $redis.sadd("disabled_notifications_#{ current_character.id }", type_name)
      end
    end
  end
end
