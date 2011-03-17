module Notification
  class SendGift < Base
    def items
      @items ||= Item.gifts_for(character).all(:limit => 3)
    end
  end
end