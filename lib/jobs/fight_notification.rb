module Jobs
  class FightNotification < Struct.new(:session, :fight_id)
    def perform
      if fight = Fight.find_by_id(fight_id) and fight.created_at > Time.now - 15.minutes
        begin
          Publisher::Fight.deliver_notification(session.user, fight)
        rescue Facebooker::Session::TooManyUserActionCalls
          logger.error "[Fight Notification] User action call limit exceeded"
        rescue Curl::Err::GotNothingError
          logger.error "[Fight Notification] Facebook did not returned result"
        end
      end
    end
  end
end