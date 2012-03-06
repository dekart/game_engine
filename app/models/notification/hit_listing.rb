module Notification
  class HitListing < Base
    def victim
      @victim ||= Character.find(data[:victim_id])
    end
  end
end
