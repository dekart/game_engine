module Notification
  class Information < Base
    def mark_read_manually
      true
    end

    def message
      @message ||= ::Message.find_by_id(data[:message_id])
    end
  end
end
