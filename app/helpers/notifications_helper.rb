module NotificationsHelper
  def close_notification_event(notification)
    %{
      $(document).one('close.dialog', function(){
        $.post('/notifications/mark_read', {type: '#{ notification.class_to_type }'});
      });
    }
  end
end
