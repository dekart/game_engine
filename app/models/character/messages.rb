class Character
  module Messages
    def message
      @message ||= Message.with_state(:visible).by_level(self.level).first
    end
  end
end
