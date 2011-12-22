module Notification
  class ClanApplicationState < Base
    def clan
      @clan ||= Clan.find(data[:clan_id])
    end
    
    def status
      @status ||= data[:status]
    end
    
    # A person who asked to join to the clan
    def applicant
      @applicant ||= Character.find(data[:applicant_id])
    end
  end
end