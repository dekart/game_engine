module Notification
  class StatusApplication < Base
    def clan
      @clan ||= Clan.find(data[:clan_id])
    end
    
    def status
      @status ||= data[:status]
    end
  end
end