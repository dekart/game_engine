module Notification
  class WallPost < Base
    def author
      @author ||= Character.find(data[:author_id])
    end
  end 
end