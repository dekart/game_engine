module Notification
  class ClanInvitationState < Base
    def clan
      @clan ||= Clan.find(data[:clan_id])
    end
    
    def status
      @status ||= data[:status]
    end
    
    def character
      @character ||= Character.find(data[:character_id])
    end
  end
end