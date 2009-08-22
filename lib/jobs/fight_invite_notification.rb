module Jobs
  class FightInviteNotification < Struct.new(:session, :victim)
    def perform
      begin
        Publisher::Fight.deliver_invitation(session.user, victim)
      rescue Facebooker::Session::TooManyUserActionCalls
        logger.error "[Fight Notification] User action call limit exceeded"
      rescue Curl::Err::GotNothingError
        logger.error "[Fight Notification] Facebook did not returned result"
      end
    end
  end
end