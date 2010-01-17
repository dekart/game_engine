module Jobs
  class WelcomeNotification < Struct.new(:user_id)
    include Jobs::Common

    def perform
      if user = User.find_by_id(user_id)
        begin
          Publisher::Character.deliver_welcome_notification(user)
        rescue Facebooker::Session::TooManyUserActionCalls
          logger.error "[Invitation Notification] User action call limit exceeded"
        rescue Curl::Err::GotNothingError
          logger.error "[Invitation Notification] Facebook did not returned result"
        end
      end
    end
  end
end