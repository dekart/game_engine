module Notification
  class HitListed < Base
    def victim
      @victim ||= Character.find(data[:victim_id])
    end
  end
end
