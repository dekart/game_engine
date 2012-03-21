module Notification
  class ClanInvitationState < Base
    def clan
      @clan ||= Clan.find(data[:clan_id])
    end
    
    def status
      @status ||= data[:status]
    end
    
    def applicant
      @applicant ||= Character.find(data[:character_id])
    end
  end
end