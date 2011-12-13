module Notification
  class AcceptedApplication < Base
    def clan
      @clan ||= Clan.find(data[:clan_id])
    end
  end
end