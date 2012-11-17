module Notification
  class NewWallPost < Base
    def author
      @author ||= Character.find(data[:author_id])
    end
  end
end