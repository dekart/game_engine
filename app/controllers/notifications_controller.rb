class NotificationsController < ApplicationController
  def index
    @notifications = current_character.notifications.fetch

    respond_to do |format|
      format.js { render :layout => false }
    end
  end

  def mark_read
    @notification = current_character.notifications.find_by_type(params[:type])

    @notification.delete
  end

  def disable
    @type = Notification::Base.type_to_class(params[:type].to_sym)

    current_character.notifications.disable_type(params[:type])
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

        current_character.notifications.enable_type(type_name)
      else

        current_character.notifications.disable_type(type_name)
      end
    end
  end
end
