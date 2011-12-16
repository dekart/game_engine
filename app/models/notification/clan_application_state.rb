module Notification
  class ClanApplicationState < Base
    def clan
      @clan ||= Clan.find(data[:clan_id])
    end
    
    def status
      @status ||= data[:status]
    end
  end
end