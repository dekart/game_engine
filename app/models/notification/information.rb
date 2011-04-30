module Notification
  class Information < Base
    def message
      @message ||= ::Message.find_by_id(data[:message_id])
    end
  end
end
