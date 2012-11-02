class Character
  module Messages
    def message
      messages = Message.with_state(:visible).by_level(self.level)

      messages.detect{|message| show_message?(message) }
    end

    def show_message?(message)
      return false if message.displayed_to_character?(self)

      message.mark_displayed(self)

      true
    end
  end
end
